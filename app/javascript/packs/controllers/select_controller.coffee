import { Controller } from "stimulus"

export default class extends Controller
  @targets = ['select', 'option', 'placeholder']
  @values = { isRendered: Boolean }

  connect: ->
    if !@isRenderedValue
      @options = [...@selectTarget.querySelectorAll('option')]
      @selectTarget.insertAdjacentHTML('afterend', @template())
      @isRenderedValue = true

  template: ->
    "<div class='dropdown' data-controller='dropdown' data-dropdown-target='wrapper'>
      <button type='button' data-action='dropdown#toggle click@window->dropdown#hide' id='#{@selectTarget.dataset.id unless @selectTarget.dataset.id}' class='#{@selectTarget.dataset.classes}' aria-expanded='false' aria-haspopup='true' tabindex='0'>
        <span class='select__selected' data-select-target='placeholder'>#{@selectTarget.querySelector('option:checked').innerText}</span>
        <span class='button__icon'>
          <svg xmlns='http://www.w3.org/2000/svg' width='100%' height='100%' fill='none' viewBox='0 0 24 24' stroke='currentColor' stroke-width='2' stroke-linecap='round'' stroke-linejoin='round' class='w-4 h-4'>
            <polyline points='18 15 12 9 6 15'></polyline>
          </svg>
        </span>
      </button>
      <ul class='dropdown__content dropdown__list pretty-scroll w-full max-h-96' role='list'>
        #{@options.map((option) =>
          "<li class='dropdown__option' data-value='#{option.value}' data-text='#{option.innerText}' data-select-target='option' data-action='click->select#onClick click->dropdown#toggle' role='option'>
            <button type='button' class='dropdown__button'>spot no. #{option.innerText}</button>
          </li>"
        ).join('')}
      </ul>
    </div>"

  onClick: (e) ->
    @selectTarget.value = e.currentTarget.dataset.value
    @placeholderTarget.innerText = e.currentTarget.dataset.text