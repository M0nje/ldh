FactoryBot.define do
  # Sop
  factory(:sop) do
    title { 'This Sop' }
    with_project_contributor
  
    after_create do |sop|
      if sop.content_blob.blank?
        sop.content_blob = Factory.create(:content_blob, original_filename: 'sop.pdf',
                                          content_type: 'application/pdf', asset: sop, asset_version: sop.version)
      else
        sop.content_blob.asset = sop
        sop.content_blob.asset_version = sop.version
        sop.content_blob.save
      end
    end
  end
  
  factory(:public_sop, parent: :sop) do
    policy { Factory(:downloadable_public_policy) }
  end
  
  factory(:min_sop, class: Sop) do
    with_project_contributor
    title { 'A Minimal Sop' }
    projects { [Factory(:min_project)] }
    after_create do |sop|
      sop.content_blob = Factory.create(:min_content_blob, content_type: 'application/pdf', asset: sop, asset_version: sop.version)
    end
  end
  
  factory(:max_sop, class: Sop) do
    with_project_contributor
    title { 'A Maximal Sop' }
    description { 'How to run a simulation in GROMACS' }
    discussion_links { [Factory.build(:discussion_link, label:'Slack')] }
    projects { [Factory(:max_project)] }
    assays { [Factory(:public_assay)] }
    workflows {[Factory.build(:workflow, policy: Factory(:public_policy))]}
    relationships {[Factory(:relationship, predicate: Relationship::RELATED_TO_PUBLICATION, other_object: Factory(:publication))]}
    after_create do |sop|
      sop.content_blob = Factory.create(:min_content_blob, content_type: 'application/pdf', asset: sop, asset_version: sop.version)
      sop.annotate_with(['Sop-tag1', 'Sop-tag2', 'Sop-tag3', 'Sop-tag4', 'Sop-tag5'], 'tag', sop.contributor)
      sop.save!
    end
    other_creators { 'Blogs, Joe' }
    assets_creators { [AssetsCreator.new(affiliation: 'University of Somewhere', creator: Factory(:person, first_name: 'Some', last_name: 'One'))] }
  end
  
  factory(:doc_sop, parent: :sop) do
    association :content_blob, factory: :doc_content_blob
  end
  
  factory(:odt_sop, parent: :sop) do
    association :content_blob, factory: :odt_content_blob
  end
  
  factory(:pdf_sop, parent: :sop) do
    association :content_blob, factory: :pdf_content_blob
  end
  
  # A SOP that has been registered as a URI
  factory(:url_sop, parent: :sop) do
    association :content_blob, factory: :url_content_blob
  end
  
  # Sop::Version
  factory(:sop_version, class: Sop::Version) do
    association :sop
    projects { sop.projects }
    after_create do |sop_version|
      sop_version.sop.version += 1
      sop_version.sop.save
      sop_version.version = sop_version.sop.version
      sop_version.title = sop_version.sop.title
      sop_version.save
    end
  end
  
  factory(:sop_version_with_blob, parent: :sop_version) do
    after_create do |sop_version|
      if sop_version.content_blob.blank?
        sop_version.content_blob = Factory.create(:pdf_content_blob,
                                                  asset: sop_version.sop,
                                                  asset_version: sop_version.version)
      else
        sop_version.content_blob.asset = sop_version.sop
        sop_version.content_blob.asset_version = sop_version.version
        sop_version.content_blob.save
      end
    end
  end
  
  factory(:api_pdf_sop, parent: :sop) do
    association :content_blob, factory: :blank_pdf_content_blob
  end
end
