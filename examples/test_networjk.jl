using TreeNodeClassification
using GraphPlot
using Colors
using Graphs

##
# Generate a graph with known classes
known_node_classes = Vector{Any}(undef, 11)
g = path_graph(7)
add_edge!(g, 1, 7)
add_vertices!(g, 4)

known_node_classes[1] = "Root"
known_node_classes[2] = "Root"
known_node_classes[7] = "Root"

known_node_classes[3:6] .= "Bulk"

# Dense Sprout
add_edge!(g, 7, 8)
add_edge!(g, 7, 5)
add_edge!(g, 7, 4)
add_edge!(g, 7, 3)
add_edge!(g, 7, 2)
known_node_classes[8] = "Dense Sprout"

# Sparse Sprout
add_edge!(g, 1, 9)
known_node_classes[9] = "Sparse Sprout"

# Inner Tree Node and Proper Leaf
add_edge!(g, 2, 10)
add_edge!(g, 10, 11)
known_node_classes[10] = "Inner Tree Node"
known_node_classes[11] = "Proper Leaf"

# Tree Node Classification
thershold = 5
node_class = full_node_classification(g, 1000, thershold)

nodecolor = [colorant"lightseagreen", colorant"orange", colorant"grey", colorant"brown", colorant"darkblue", colorant"steelblue"]
membership = ones(Int, nv(g))

for j in 1:nv(g)
    if node_class[j] == "Proper Leaf"
        membership[j] = 2
    elseif node_class[j] == "Root"
        membership[j] = 4
    elseif node_class[j] == "Bulk"
        membership[j] = 3
    elseif node_class[j] == "Dense Sprout"
        membership[j] = 5
    elseif node_class[j] == "Sparse Sprout"
        membership[j] = 6
    end
end

# membership color
nodefillc = nodecolor[membership]
gplot(g, nodefillc = nodefillc)