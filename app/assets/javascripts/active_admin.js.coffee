#= require active_admin/base
#= require activeadmin_addons/all
#= require jquery-ui/widgets/autocomplete
#= require autocomplete-rails
#= require jquery.qrcode.min.js

$ ->
  $('div.qrcode').each ->
    $this = $(this)
    $this.qrcode text: $this.data('provisioning-uri')
    return
  return
