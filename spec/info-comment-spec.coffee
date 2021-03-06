InfoComment = require '../lib/info-comment'

describe "InfoComment", ->
  [editor, buffer, languageMode, workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('info-comment')

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.workspace.open('sample.js', autoIndent: false).then (ed) ->
        editor = ed
        {buffer, languageMode} = editor

  afterEach ->
    atom.packages.deactivatePackages()
    atom.packages.unloadPackages()

  describe "after activating package", ->
    beforeEach ->
      atom.commands.dispatch workspaceElement, 'info-comment:toggle'
      waitsForPromise ->
        activationPromise

    it 'should load', ->
      runs ->
        expect(atom.packages.isPackageActive('info-comment')).toBe true

    it "should recognize commented code", ->
      expect(languageMode.rowRangeForCommentAtBufferRow(38)).toEqual [37,39]
      expect(languageMode.rowRangeForCommentAtBufferRow(30)).toBeFalsy()

  describe "when the info-comment:toggle event is triggered", ->
    toggleComment = (callback) ->
      atom.commands.dispatch workspaceElement, 'info-comment:toggle'
      waitsForPromise -> activationPromise
      runs(callback)

    expectCommented = ->
      expect(buffer.lineForRow(0)).toBe '/* '
      expect(buffer.lineForRow(1)).toBe ' * findFirst(array, func)'
      expect(buffer.lineForRow(2)).toBe ' * Find the first element in the array which returns true when passed to func.'
      expect(buffer.lineForRow(3)).toBe ' * '
      expect(buffer.lineForRow(4)).toBe ' * inputs:'
      expect(buffer.lineForRow(5)).toBe ' *     array: the array to search'
      expect(buffer.lineForRow(6)).toBe ' *     func: the function to pass each array element to'
      expect(buffer.lineForRow(7)).toBe ' *         func arguments are (e, i, a)'
      expect(buffer.lineForRow(8)).toBe ' *         e - the current array element'
      expect(buffer.lineForRow(9)).toBe ' *         i - the current array index'
      expect(buffer.lineForRow(10)).toBe ' *         a - the array itself'
      expect(buffer.lineForRow(11)).toBe ' * '
      expect(buffer.lineForRow(12)).toBe ' * output:'
      expect(buffer.lineForRow(13)).toBe ' *     the first element of array at which func returns true'
      expect(buffer.lineForRow(14)).toBe ' *     or null'
      expect(buffer.lineForRow(15)).toBe ' * '
      expect(buffer.lineForRow(16)).toBe ' * Example usage:'
      expect(buffer.lineForRow(17)).toBe ' *     var people = ['
      expect(buffer.lineForRow(18)).toBe ' *         { name: "John", age: 25 },'
      expect(buffer.lineForRow(19)).toBe ' *         { name: "Sally", age: 40 },'
      expect(buffer.lineForRow(20)).toBe ' *         { name: "Bob", age: 77 },'
      expect(buffer.lineForRow(21)).toBe ' *         { name: "Jenifer", age: 12}'
      expect(buffer.lineForRow(22)).toBe ' *     ]'
      expect(buffer.lineForRow(23)).toBe ' * '
      expect(buffer.lineForRow(24)).toBe ' *     // Returns { name: "Sally", age: 40 }'
      expect(buffer.lineForRow(25)).toBe ' *     findFirst(people, function(person) {'
      expect(buffer.lineForRow(26)).toBe ' *         return person.age > 30;'
      expect(buffer.lineForRow(27)).toBe ' *     });'
      expect(buffer.lineForRow(28)).toBe ' */'
      expect(buffer.lineForRow(29)).toBe ''
      expect(buffer.lineForRow(30)).toBe 'function findFirst(array, func) {'
      expect(buffer.lineForRow(31)).toBe '    if (array instanceof Array)'
      expect(buffer.lineForRow(32)).toBe '        for (var i = 0; i < array.length; i++)'
      expect(buffer.lineForRow(33)).toBe '            if (func(array[i]), i, array)'
      expect(buffer.lineForRow(34)).toBe '                return array[i];'
      expect(buffer.lineForRow(35)).toBe ''
      expect(buffer.lineForRow(36)).toBe '    return null;'
      expect(buffer.lineForRow(37)).toBe '}'
      expect(buffer.lineForRow(38)).toBe ''
      expect(buffer.lineForRow(39)).toBe '/*'
      expect(buffer.lineForRow(40)).toBe ' * Pre-commented'
      expect(buffer.lineForRow(41)).toBe ' */'
      expect(buffer.lineForRow(42)).toBe ''

    expectUncommented = ->
      expect(buffer.lineForRow(0)).toBe 'findFirst(array, func)'
      expect(buffer.lineForRow(1)).toBe 'Find the first element in the array which returns true when passed to func.'
      expect(buffer.lineForRow(2)).toBe ''
      expect(buffer.lineForRow(3)).toBe 'inputs:'
      expect(buffer.lineForRow(4)).toBe '    array: the array to search'
      expect(buffer.lineForRow(5)).toBe '    func: the function to pass each array element to'
      expect(buffer.lineForRow(6)).toBe '        func arguments are (e, i, a)'
      expect(buffer.lineForRow(7)).toBe '        e - the current array element'
      expect(buffer.lineForRow(8)).toBe '        i - the current array index'
      expect(buffer.lineForRow(9)).toBe '        a - the array itself'
      expect(buffer.lineForRow(10)).toBe ''
      expect(buffer.lineForRow(11)).toBe 'output:'
      expect(buffer.lineForRow(12)).toBe '    the first element of array at which func returns true'
      expect(buffer.lineForRow(13)).toBe '    or null'
      expect(buffer.lineForRow(14)).toBe ''
      expect(buffer.lineForRow(15)).toBe 'Example usage:'
      expect(buffer.lineForRow(16)).toBe '    var people = ['
      expect(buffer.lineForRow(17)).toBe '        { name: "John", age: 25 },'
      expect(buffer.lineForRow(18)).toBe '        { name: "Sally", age: 40 },'
      expect(buffer.lineForRow(19)).toBe '        { name: "Bob", age: 77 },'
      expect(buffer.lineForRow(20)).toBe '        { name: "Jenifer", age: 12}'
      expect(buffer.lineForRow(21)).toBe '    ]'
      expect(buffer.lineForRow(22)).toBe ''
      expect(buffer.lineForRow(23)).toBe '    // Returns { name: "Sally", age: 40 }'
      expect(buffer.lineForRow(24)).toBe '    findFirst(people, function(person) {'
      expect(buffer.lineForRow(25)).toBe '        return person.age > 30;'
      expect(buffer.lineForRow(26)).toBe '    });'
      expect(buffer.lineForRow(27)).toBe ''

    it "comments/uncomments selected text", ->
      editor.setSelectedBufferRange([[0, 0], [27, 0]])

      atom.config.set('info-comment', true)

      expectUncommented()

      toggleComment ->
        expectCommented()
        toggleComment ->
          expectUncommented()
