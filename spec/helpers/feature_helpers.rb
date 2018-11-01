module FeatureHelpers
  def login_as(admin_user)
    visit admin_user_session_path
    fill_in 'admin_user[email]', with: admin_user.email
    fill_in 'admin_user[password]', with: admin_user.password
    click_button 'Login'
  end

  def fill_seed(kind, attributes, has_many = true, index = 0)
    attributes.each do |key, value|
      if has_many
      	fill_in "issue[#{kind}_seeds_attributes][#{index}][#{key}]",
	  with: value
      else
        fill_in "issue[#{kind}_seed_attributes][#{key}]",
	  with: value
      end
    end
  end

  def fill_attachment(kind, ext = 'jpg', has_many = true, index = 0, att_index = 0, accented = false)
    wait_for_ajax
    path = if has_many
      "issue[#{kind}_attributes][#{index}][attachments_attributes][#{att_index}][document]"
    else
      "issue[#{kind}_attributes][attachments_attributes][#{att_index}][document]"
    end
    filename = if accented
      "./spec/fixtures/files/áñ_simple_微信图片.#{ext}"
    else
      if ext == ext.upcase
        "./spec/fixtures/files/simple_upper.#{ext}"
      else 
        "./spec/fixtures/files/simple.#{ext}"
      end
    end
    attach_file(path,
        File.absolute_path(filename), wait: 10.seconds)
  end
end

RSpec.configuration.include FeatureHelpers, type: :feature
