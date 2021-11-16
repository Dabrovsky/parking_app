import { Controller } from "stimulus"

export default class extends Controller
  @targets = ['modal', 'background', 'container', 'button']

  connect: ->
    @body = document.body
    @modalUrl = "#{@data.get('url')}#{if @data.get('params') then @data.get('params') else ''}"
    @showSpinner = @data.get('spinner') == 'false'

  _closeModal: ->
    @body.classList.remove('modal-open')
    @backgroundTarget.remove()

  open: ->
    @buttonTarget.classList.add('spinner') unless @showSpinner
    fetch(@modalUrl).then (resp) =>
      resp.text().then (resp) =>
        setTimeout(() =>
          @body.classList.add('modal-open')
          @modalTarget.insertAdjacentHTML('beforeend', resp)
          @buttonTarget.classList.remove('spinner') unless @showSpinner
        , 500)

  close: (e) ->
    unless e.currentTarget.classList.contains('modal__close') or e.target == @containerTarget
      return
    @_closeModal()

  closeByEsc: (e) ->
    if e.keyCode == 27
      @_closeModal()