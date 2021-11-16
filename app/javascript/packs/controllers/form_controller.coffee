import { Controller } from 'stimulus'

export default class extends Controller
  @targets = ['form', 'button', 'timezone']
  @values = { sending: Boolean }

  connect: ->
    @id = @data.get('id')
    @timezoneTarget.value = Intl.DateTimeFormat().resolvedOptions().timeZone if @hasTimezoneTarget

  sendingValueChanged: ->
    if @sendingValue then @buttonTarget.classList.add('spinner') else @buttonTarget.classList.remove('spinner')

  _showError: (selector, error) ->
    element = @formTarget.querySelector("##{selector}")
    element.classList.add('error')
    @formTarget.querySelector("label[for=#{selector}]").classList.add('error')
    element.insertAdjacentHTML('afterEnd', "<div class='form__error'><abbr>*</abbr> #{error}</div>")

  _clearErrors: ->
    @formTarget.querySelectorAll('.error').forEach (error) =>
      error.classList.remove('error')
    @formTarget.querySelectorAll('.form__error').forEach (error) =>
      error.remove()

  onSubmit: ->
    @sendingValue = !@sendingValue

  onError: (event) ->
    [data, status, xhr] = event.detail
    resp = JSON.parse(xhr.response)
    @_clearErrors()

    if resp.errors
      setTimeout(() =>
        for i, key of Object.keys(resp.errors)
          @_showError("#{@id}_#{key}", resp.errors[key].toString())

        @sendingValue = false
      , 500)