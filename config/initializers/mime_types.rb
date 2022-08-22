# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register "application/vnd.api+json", :json
Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx

MimeMagic.add('application/vnd.openxmlformats-officedocument.wordprocessingml.document', magic: [[0..2000, 'word/']])
