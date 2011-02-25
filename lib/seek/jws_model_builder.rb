require 'hpricot'
require 'rest_client'
require 'libxml'

module Seek

  class AnnotationTriplet
    attr_accessor :full_name,:urn,:qualifier
    def initialize full_name,urn,qualifier
      @full_name=full_name
      @urn=urn
      @qualifier=qualifier
    end
  end

  class JWSModelBuilder

    include ModelTypeDetection

    BASE_URL = "#{JWS_ONLINE_ROOT}/webMathematica/Examples/"
    SIMULATE_URL = "#{JWS_ONLINE_ROOT}/webMathematica/upload/uploadNEW.jsp"
    MOCKED_RESPONSE=true

    def is_supported? model
      model.content_blob.file_exists? && (is_sbml?(model) || is_dat?(model))
    end

    def dat_to_sbml_url
      "#{BASE_URL}JWSconstructor_panels/datToSBMLstageII.jsp"
    end

    def saved_dat_download_url savedfile
      "#{BASE_URL}JWSconstructor_panels/#{savedfile}"
    end

    def builder_url
      "#{BASE_URL}JWSconstructor_panels/DatFileReader_xml.jsp"
    end

    def annotator_url
      "#{BASE_URL}JWSconstructor_panels/AnnotatorReader_xml.jsp"
    end

    def upload_dat_url
      builder_url+"?datFilePosted=true"
    end

    def upload_sbml_url
      "#{SIMULATE_URL}?SBMLFilePostedToIFC=true&xmlOutput=true"
    end

    def simulate_url
      SIMULATE_URL
    end

    def sbml_download_url savedfile
      modelname=savedfile.gsub("\.dat", "")
      url=""
      response = RestClient.post(dat_to_sbml_url, :modelName=>modelname) do |response, request, result,
        &block |
        if [301, 302, 307].include? response.code
          url=response.headers[:location]
        else
          raise Exception.new("Redirection expected to converted dat file")
        end
      end
      url
    end

    def construct params

      return process_response_body(dummy_response_xml) if MOCKED_RESPONSE

      required_params=["assignmentRules", "annotationsReactions", "annotationsSpecies", "modelname", "parameterset", "kinetics", "functions", "initVal", "reaction", "events", "steadystateanalysis", "plotGraphPanel", "plotKineticsPanel", ""]
      url = builder_url
      form_data = {}
      required_params.each do |p|
        form_data[p]=params[p] if params.has_key?(p)
      end

      response = Net::HTTP.post_form(URI.parse(url), form_data)

      if response.instance_of?(Net::HTTPInternalServerError)
        raise Exception.new(response.body.gsub(/<head\>.*<\/head>/, ""))
      end

      process_response_body(response.body)
    end

    def builder_content model

        return process_response_body(dummy_response_xml) if MOCKED_RESPONSE

        filepath=model.content_blob.filepath

        #this is necessary to get the correct filename and especially extension, which JWS relies on
        tmpfile = Tempfile.new(model.original_filename)
        FileUtils.cp(filepath, tmpfile.path)

        if (is_sbml? model)
          #        response = RestClient.post(upload_sbml_url,:upfile=>tmpfile.path,:multipart=>true) { |response, request, result, &block|
          #          if [301, 302, 307].include? response.code
          #            response.follow_redirection(request, result, &block)
          #          else
          #            response.return!(request, result, &block)
          #          end
          #        }
          part=Multipart.new("upfile", filepath, model.original_filename)
          response = part.post(upload_sbml_url)
          if response.code == "302"
            uri = URI.parse(response['location'])
            req = Net::HTTP::Get.new(uri.request_uri)
            response = Net::HTTP.start(uri.host, uri.port) { |http|
              http.request(req)
            }
          elsif response.code == "404"
            raise Exception.new("Page not found on JWS Online for url: #{upload_sbml_url}")
          elsif response.code == "500"
            raise Exception.new("Server error on JWS Online for url: #{upload_sbml_url}")
          else
            raise Exception.new("Expected a redirection from JWS Online but got #{response.code}, for url: #{upload_sbml_url}")
          end
        elsif (is_dat? model)
          response = RestClient.post(upload_dat_url, :uploadedDatFile=>tmpfile, :filename=>model.original_filename, :multipart=>true) { |response, request, result, &block |
          if [301, 302, 307].include? response.code
            response.follow_redirection(request, result, &block)
          else
            response.return!(request, result, &block)
          end
          }
        end

        if response.instance_of?(Net::HTTPInternalServerError)
          raise Exception.new(response.body.gsub(/<head\>.*<\/head>/, ""))
        end

        process_response_body(response.body)
    end

    def simulate saved_file
      url=simulate_url
      response = RestClient.post(url, :savedfile=>saved_file, :multipart=>true) { |response, request, result, &block |
      if [301, 302, 307].include? response.code
        response.follow_redirection(request, result, &block)
      else
        response.return!(request, result, &block)
      end
      }

      extract_applet(response.body)
    end

    def saved_file_builder_content saved_file
      model_name=saved_file.gsub("\.dat", "")
      response = RestClient.get(builder_url, :params=>{:loadModel=>model_name, :userModel=>true})

      if response.instance_of?(Net::HTTPInternalServerError)
        raise Exception.new(response.body.gsub(/<head\>.*<\/head>/, ""))
      end
      process_response_body(response.body)
    end

    #ANNOTATOR STUFF

    def annotate params
      return process_annotator_response_body(dummy_annotator_response_xml) if MOCKED_RESPONSE
      required_params=["assignmentRules", "annotationsReactions", "annotationsSpecies", "modelname", "parameterset", "kinetics", "functions", "initVal", "reaction", "events", "steadystateanalysis", "plotGraphPanel", "plotKineticsPanel", ""]
      url = annotator_url
      form_data = {}
      required_params.each do |p|
        form_data[p]=params[p] if params.has_key?(p)
      end

      response = Net::HTTP.post_form(URI.parse(url), form_data)

      if response.instance_of?(Net::HTTPInternalServerError)
        raise Exception.new(response.body.gsub(/<head\>.*<\/head>/, ""))
      end

      process_response_body(response.body)

    end

    def process_annotator_response_body body
      parser = LibXML::XML::Parser.string(body, :encoding => LibXML::XML::Encoding::UTF_8)
      doc = parser.parse

      params_hash = extract_main_parameters doc
      saved_file = determine_saved_file doc
      fields_with_errors = find_reported_errors doc
      search_results = extract_search_results doc
      cached_annotations = extract_cached_annotations doc
      assigned_species_annotations,assigned_reactions_annotations = extract_assigned_annotations doc

      return params_hash, assigned_species_annotations,assigned_reactions_annotations,search_results,cached_annotations,saved_file,fields_with_errors
    end

    def extract_cached_annotations doc
      extract_annotation_symbols "//annotations/cached",doc
    end

    def extract_search_results doc
      search_node=doc.find_first("//annotations/search")
      search_results = {}
      if search_node
        search_term = search_node.find_first("parameter").content.strip
        search_results[search_term]=extract_annotation_symbols "results",search_node
      end
      search_results
    end

    def extract_assigned_annotations doc
      species_names,reaction_names = extract_species_and_reaction_names doc
      species_annotation_hash = extract_annotation_symbols "//annotations/assigned/species",doc
      species_annotation_hash = synchronise_hash species_names,species_annotation_hash

      reactions_annotation_hash = extract_annotation_symbols "//annotations/assigned/reactions",doc
      reactions_annotation_hash = synchronise_hash reaction_names,reactions_annotation_hash

      return species_annotation_hash,reactions_annotation_hash

    end

    def synchronise_hash keys,hash,default=[]
      (hash.keys - keys).each {|key| hash.delete(key)}
      keys.each do |key|
        hash[key]=default unless hash.has_key?(key)
      end
      hash
    end

    def extract_annotation_symbols root_xpath,doc
      root_xpath += "/" unless root_xpath.end_with? "/"
      xpath=root_xpath + "symbol"
      symbols={}
      doc.find(xpath).each do |symbol|
        symbols[symbol.attributes["id"]] = extract_triplets(symbol)
      end
      symbols
    end

    def extract_triplets symbol
      symbol.find("triplet").collect do |triplet|
        full_name = triplet.find_first("ReadName").content
        urn = triplet.find_first("URN").content
        qualifier = triplet.find_first("Qualifier").content
        AnnotationTriplet.new full_name,urn,qualifier
      end
    end

    def extract_species_and_reaction_names doc
      species = []
      reactions = []
      species_names_node = doc.find_first("//speciesNames")
      species_names_node.children.each do |child|
        if !child.nil? && child.name == "name"
          species << child.content.strip
        end
      end unless species_names_node.nil?

      reaction_names_node = doc.find_first("//reactionsNames")
      reaction_names_node.children.each do |child|
        if !child.nil? && child.name == "name"
          reactions << child.content.strip
        end
      end unless reaction_names_node.nil?

      return species,reactions
    end

    private

    def extract_applet body
      doc = Hpricot(body)
      element = doc.search("//object").first
      element.at("param").before(%!<param name="codebase" value="#{BASE_URL}"/>!)
      element.to_s
    end

    def process_response_body body

      parser = LibXML::XML::Parser.string(body, :encoding => LibXML::XML::Encoding::UTF_8)
      doc = parser.parse
      param_values = extract_main_parameters doc

      saved_file = determine_saved_file doc
      objects_hash = create_objects_hash doc
      fields_with_errors = find_reported_errors doc

      #FIXME: temporary fix to as the builder validator always reports a problem with "functions"
      fields_with_errors.delete("functions")
      return param_values, saved_file, objects_hash, fields_with_errors
    end

    def find_reported_errors doc
      errors=[]

      doc.find("//errorinfo/error").each do |error_report|
        value=error_report.content.strip
        name=error_report.attributes['id']
        errors << name unless value=="0"
      end

      return errors
    end

    def create_objects_hash doc
      objects_hash = {}
      doc.find("//form[@id='main']/objects/object").each do |node|
        id=node.attributes['id']
        if ["reactionImage", "kineticsImage"].include?(id)
          url=node.content.strip
          url = BASE_URL + "JWSconstructor_panels/" + url
          objects_hash[id]=url
          #objects_hash[id] = %!<object data="#{url}" id="#{element_id}" alt="Network structure" class="reContent"></object>!
        end
      end
      objects_hash
    end

    def extract_main_parameters doc
      params={}
      doc.find("//form[@id='main']/*/parameter").each do |node|
        unless node.attributes['id'].nil?
          id=node.attributes['id']
          params[id]=node.content.strip
        end
      end
      params
    end

    def determine_saved_file doc
      file=nil
      node = doc.find_first("//form[@id='simulate']/parameters/parameter[@id='savedfile']")
      unless node.nil?
        file=node.content.strip
      end
      file
    end


    #only used for testing and development purposes
    def dummy_response_xml
      path="#{RAILS_ROOT}/test/example_jws_response.xml"
      File.open(path, "rb").read
    end

    #only used for testing and development purposes
    def dummy_annotator_response_xml
      path="#{RAILS_ROOT}/test/annotator_jws_response.xml"
      File.open(path, "rb").read
    end
  end

end