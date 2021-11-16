import { Controller } from "stimulus"

export default class extends Controller
  @targets = ['wrapper', 'button', 'checkbox']
  @values = { open: Boolean }

  connect: ->
    @toggleClass = 'open'
    @body = document.body

  _open: ->
    @wrapperTarget.classList.add(@toggleClass)

  _close: ->
    @wrapperTarget.classList.remove(@toggleClass)

  toggle: ->
    @openValue = !@openValue

  openValueChanged: ->
    if @openValue then @_open() else @_close()

  hide: (event) ->
    if @element.contains(event.target) == false && @openValue
      @openValue = false

  checked: (e) ->
    str = [...@checkboxTargets].filter((checkbox) =>
      if checkbox.checked then checkbox else null).map (checkbox) =>
        checkbox.dataset.text
    @buttonTarget.innerHTML = "<span>#{str.join(', ')}</span><span class='button__icon'><i class='icon-down-open-mini' aria-hidden='true'></i></span>"