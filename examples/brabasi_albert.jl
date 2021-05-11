using TreeNodeClassification
using GraphPlot
using Colors
using LightGraphs

N = 100
k = 1

g = barabasi_albert(N,k)
thershold = 5

node_class = full_node_classification(g, 1000, thershold)

nodecolor = [colorant"lightseagreen", colorant"orange", colorant"grey", colorant"brown", colorant"darkblue", colorant"steelblue"]
membership = ones(Int,nv(g))

for j in 1:nv(g)
    if node_class[j] == "Proper Leave"
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