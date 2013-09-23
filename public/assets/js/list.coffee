$ ->
  class ListModel extends Backbone.Model

  class ListCollection extends Backbone.Collection
    model: ListModel
    url: "/api/list"

  class ListView extends Backbone.View
    tagName: "tr"

    template: _.template($("#js-list-template").html())

    events:
      "click .js-delete": "delete"

    initialize: ->
      @listenTo @model, "add", @render
      @listenTo @model, "destroy", @remove

    delete: ->
      @model.destroy({ wait: true, merge: true })

    render: ->
      @$el.html @template(@model.toJSON())
      this

  class ListsView extends Backbone.View
    el: "#js-list"

    initialize: ->
      @listenTo @collection, "add", @add
      @listenTo @collection, "destroy"
      @collection.fetch()

    add: (list)->
      view = new ListView(model: list)
      @$el.append view.render().el


  new ListsView(collection: new ListCollection)
