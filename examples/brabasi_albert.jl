using TreeNodeClassification
using GraphPlot
using Colors
using LightGraphs

N = 100
k = 1

g = barabasi_albert(N,k)
thershold = 5

b, r, l, i_t, s, d = full_node_classification(g, 1000, thershold)

nodecolor = [colorant"lightseagreen", colorant"orange", colorant"grey", colorant"brown", colorant"darkblue", colorant"steelblue"]
membership = ones(Int,nv(g))

for j in 1:nv(g)
    if j ∈ l
        membership[j] = 2
    elseif j ∈ r
        membership[j] = 4
    elseif j ∈ b
        membership[j] = 3
    elseif j ∈ d
        membership[j] = 5
    elseif j ∈ s
        membership[j] = 6
    end
end

# membership color
nodefillc = nodecolor[membership]
gplot(g, nodefillc = nodefillc)