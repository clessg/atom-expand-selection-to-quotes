{Range} = require 'atom'

# With cursor at X, the command should select the string:
# "Here is the X cursor"
#
# With cursor at X, the command should select the single quoted string:
# "Here is 'the X cursor' now"
#
# This one doesn't work right yet. We're assuming that the first quote is
# the one we want, which isn't always true.
# With cursor at X, the command should select the double quoted string:
# "Here the cursor is 'outside' the X selection"

class ExpandSelectionToQuotes
  constructor: (@editor) ->
    return if editor.cursors.length > 1
    @addSelection()

  addSelection: ->
    quoteRange = @getQuoteRange()
    @editor.addSelectionForBufferRange(quoteRange) if quoteRange

  getCursorPosition: ->
    @editor.cursors[0].getBufferPosition()

  getOpeningQuotePosition: ->
    range = new Range @editor.buffer.getFirstPosition(), @getCursorPosition()
    quote = false
    @editor.buffer.backwardsScanInRange /['|"]/g, range, (obj) =>
      @quoteType = obj.matchText
      obj.stop()
      quote = obj.range.end
    quote

  getClosingQuotePosition: ->
    range = new Range @getCursorPosition(), @editor.buffer.getEndPosition()
    quote = false
    @editor.buffer.scanInRange /['|"]/g, range, (obj) =>
      obj.stop() if obj.matchText is @quoteType
      quote = obj.range.start
    quote

  getQuoteRange: ->
    opening = @getOpeningQuotePosition()
    return false unless opening?
    closing = @getClosingQuotePosition()
    return false unless closing?
    new Range opening, closing

module.exports =
  activate: ->
    atom.commands.add 'atom-text-editor', 'expand-selection-to-quotes:toggle', ->
      paneItem = atom.workspace.getActivePaneItem()
      new ExpandSelectionToQuotes(paneItem)

  ExpandSelectionToQuotes: ExpandSelectionToQuotes
