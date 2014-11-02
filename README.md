diso.view
=========

0.0.24

Description
-----------
Views!

pre release derp ... proper docs in progress but code is commented with docco output in /docs

Internal API Notes
------------------

Views provide a constructor that accepts a single @data argument consisting of the data it needs to render itself


Each view must provide a globally unique id under @id

If this is not passed in the constructor or set in the child class, one is created using [shortid](https://github.com/dylang/shortid/)


A run method that gets called in the client to attach event handlers to the view

idMap that returns and object detailing the id hierarchy through the tree of subviews


