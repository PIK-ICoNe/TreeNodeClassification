using TreeNodeClassification
using SyntheticNetworks
using GraphPlot
using Colors
using Graphs

RPG = RandomPowerGrid(100, 1, 1/5, 3/10, 1/3, 1/10, rand())
g = generate_graph(RPG)

threshold = 5
node_class = full_node_classification(g.graph, 1000, threshold)

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