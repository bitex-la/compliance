# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register "application/vnd.api+json", :json
Mime::Type.register "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :docx
Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx

[['application/vnd.openxmlformats-officedocument.wordprocessingml.document', [[0..2000, 'word/']]],].each do |magic|
  MimeMagic.add(magic[0], magic: magic[1])
end
