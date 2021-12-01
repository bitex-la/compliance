Paperclip::DataUriAdapter.register

module PatchPaperclipContentTypeDetector
  def type_from_file_contents
    type = super
    types = possible_types
    return 'application/vnd.ms-excel' if type == 'application/x-ole-storage' && types.include?('application/vnd.ms-excel')

    type
  end
end

Paperclip::ContentTypeDetector.class_eval do
  prepend PatchPaperclipContentTypeDetector
end
