module Seek
  module BioSchema
    module ResourceDecorators
      # Decorator that provides extensions for a Workflow
      class Workflow < CreativeWork
        WORKFLOW_PROFILE = 'https://bioschemas.org/profiles/ComputationalWorkflow/1.0-RELEASE/'

        FORMALPARAMETER_PROFILE = 'https://bioschemas.org/profiles/FormalParameter/1.0-RELEASE/'
        
        associated_items part_of: :collectons
        
        schema_mappings version: :version,
                        image: :image,
                        programming_language: :programmingLanguage,
                        producer: :producer,
                        inputs: :input,
                        outputs: :output,
                        license: :license,
                        part_of: :isPartOf

        def contributors
          [contributor]
        end

        def conformance
          WORKFLOW_PROFILE
        end
    
        def image
          return unless resource.diagram_exists?
          diagram_workflow_url(resource, version: resource.version, host: Seek::Config.site_base_host)
        end

         def schema_type
          ['File', 'SoftwareSourceCode', 'ComputationalWorkflow']
        end

        def programming_language
          resource.workflow_class&.title
        end

        def inputs
          formal_parameters(resource.inputs, 'inputs')
        end

        def outputs
          formal_parameters(resource.outputs, 'outputs')
        end

        def license
          Seek::License.find(resource.license)&.url
        end

        private

        def formal_parameters(properties, group_name)
          if self.title
            wf_name = self.title.downcase.gsub(/[^0-9a-z]/i, '_')
          else
            wf_name = 'dummy'
          end
          properties.collect do |property|
            {
              "@type": 'FormalParameter',
              "@id": "##{wf_name}-#{group_name}-#{property.id}",
              name: property.name || property.id,
              "dct:conformsTo": FORMALPARAMETER_PROFILE
            }
          end
        end
      end
    end
  end
end
