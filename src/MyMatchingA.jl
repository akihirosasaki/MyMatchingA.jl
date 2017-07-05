module MyMatchingA
export deferred_acceptance

function deferred_acceptance(m_prefs::Vector{Vector{Int}},f_prefs::Vector{Vector{Int}},caps::Vector{Int})
    m = length(m_prefs)
    n = length(f_prefs)
    prop_prefs = zeros(Int,m,n+1)
    resp_prefs = zeros(Int,n,m+1)
    
    for male in 1:m
        num = length(m_prefs[male])
        for p in 1:num
            prop_prefs[male,p] = m_prefs[male][p]
        end
    end
    for fem in 1:n
        numf = length(f_prefs[fem])
        for q in 1:numf
            resp_prefs[fem,q] = f_prefs[fem][q]
        end
    end

    prop_matches, resp_matches, indptr = deferred_acceptance(prop_prefs, resp_prefs, caps)

    return prop_matches,resp_matches,indptr

end

function deferred_acceptance(m_prefs::Vector{Vector{Int}},f_prefs::Vector{Vector{Int}})
    m = length(m_prefs)
    n = length(f_prefs)
    prop_prefs = zeros(Int,m,n+1)
    resp_prefs = zeros(Int,n,m+1)
    
    for male in 1:m
        num = length(m_prefs[male])
        for p in 1:num
            prop_prefs[male,p] = m_prefs[male][p]
        end
    end
    for fem in 1:n
        numf = length(f_prefs[fem])
        for q in 1:numf
            resp_prefs[fem,q] = f_prefs[fem][q]
        end
    end
    
    caps = ones(Int, size(resp_prefs, 1))
    prop_matches, resp_matches, indptr =
        deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end

# 多対一のケース
function deferred_acceptance(prop_prefs::Matrix{Int}, resp_prefs::Matrix{Int}, caps)
    m = size(prop_prefs, 1)
    n = size(resp_prefs, 1)
    
    prop_matches = fill(-1, m)
    
    prop_next_to_propose = ones(Int64, m)
    L = sum(caps)
    resp_matches = zeros(Int64, L)
    
    indptr = Array{Int}(n+1)
    indptr[1] = 1
    for i in 1:n
        indptr[i+1] = indptr[i] + caps[i]
    end    
    
    resp_rankings = (m+1)*ones(Int, m, n)    
    
    for j in 1:n       
       for i in 1:length(resp_prefs[j,:])
           b = length(resp_prefs[j,:])            
           a = resp_prefs[j,i]
           resp_rankings[a,j] = i
       end
    end
    
   @show q = resp_rankings
    
    while true
   @show     i = get_single(prop_matches)
        if i == 0
            break
        end
        if prop_next_to_propose[i] > length(prop_prefs[i])
            prop_matches[i] = 0
            continue
        end        
            

        #学生iが入りたい大学jを探す．
   @show     j = prop_prefs[i][prop_next_to_propose[i]]
        if j == 0
            prop_matches[i] = 0
            continue
        end
        
        #大学jのリストを探す
        #要修正？
   @show     p = resp_matches[indptr[j]:indptr[j+1]-1]
        
        if resp_rankings[i,j] >= m+1
            prop_next_to_propose[i] += 1
            continue
        end

        #大学jが受け入れ可能なら受け入れる．
   @show    a = findfirst(p,0)
        if a != 0
            resp_matches[indptr[j]-1+a] = i
            prop_matches[i] = j

        #大学jが定員オーバーしている場合
        else
        #大学jがiの方を選好していれば，受け入れる．
            list_comp = Array(Int, length(p))
            for k in 1:length(p)
                b = resp_rankings[p[k],j]
                list_comp[k] = b
            end
            b_max = maximum(list_comp)
            c = findfirst(resp_rankings[:,j], b_max)
            
            if resp_rankings[i,j] < resp_rankings[c,j]
                d = findfirst(resp_matches, c)
                resp_matches[d] = i
                prop_matches[i] = j
                prop_matches[c] = -1
            end
        end
   @show     prop_next_to_propose[i] += 1
    end
    
    return prop_matches, resp_matches, indptr    
end

#どこにも決まってない学生を返す．(存在しなければ0)
function get_single(partners)
    m = size(partners, 1)
    for i in 1:m
        if partners[i] == -1
          return i
        end        
    end
    return 0   
end


end



# 一対一のケース
function deferred_acceptance(prop_prefs::Matrix{Int},resp_prefs::Matrix{Int})
    caps = ones(Int, size(resp_prefs, 1))
    prop_matches, resp_matches, indptr =
        deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end