from graphviz import Digraph

# Create a new graph
dot = Digraph(comment='A Simple Pedigree')

# Add nodes for the individuals in the pedigree
dot.node('1', 'Individual 1')
dot.node('2', 'Individual 2')
dot.node('3', 'Individual 3')
dot.node('4', 'Individual 4')
dot.node('5', 'Individual 5')

# Add edges to indicate relationships between individuals
dot.edge('1', '2', 'father')
dot.edge('2', '3', 'mother')
dot.edge('1', '4', 'father')
dot.edge('4', '5', 'mother')

# Render the graph to a file
dot.render('pedigree.gv', view=True)
