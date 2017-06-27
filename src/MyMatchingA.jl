module MyMatchingA
export my_deferred_acceptance

# 多対一のケース
function my_deferred_acceptance(prop_prefs, resp_prefs, caps)
    m = size(prop_prefs, 1)
    n = size(resp_prefs, 1)
    
    prop_matches = fill(-1, m)
    
    prop_next_to_propose = ones(Int, m)
    
    resp_matches = zeros(Int, sum(caps))
    
    indptr = Array(Int,n+1)
    indptr[1] = 1
    for i in 1:n
        indptr[i+1] = indptr[i] + caps[i]
    end    
    
    resp_rankings = (m+1)*ones(Int, m, n)    
    
    for j in 1:n
       for i in 1:length(resp_prefs[j])
           b = length(resp_prefs[j])
           a = resp_prefs[j][i]
           resp_rankings[a,j] = i
       end
    end
    
    
    while true
        i = get_single(prop_matches)
        if i == 0
            break
        end
        if prop_next_to_propose[i] > length(prop_prefs[i])
            prop_matches[i] = 0
            continue
        end        
            

        #学生iが入りたい大学jを探す．
        j = prop_prefs[i][prop_next_to_propose[i]]

        #大学jのリストを探す
        p = resp_matches[indptr[j]:indptr[j+1]-1]
        
        if resp_rankings[i,j] >= m+1
            prop_next_to_propose[i] += 1
            continue
        end

        #大学jが受け入れ可能なら受け入れる．
        a = findfirst(p,0)
        if a != 0
            resp_matches[indptr[j]-1+a] = i
            prop_matches[i] = j

        #大学jが定員オーバーしている場合
        else
        #大学jがiの方を選好していれば，受け入れる．
            for k in 1:length(p)
                b = maximum(resp_rankings[p[k],j])
                c = findfirst(resp_rankings[:,j], b)
            end
            if resp_rankings[i,j] < resp_rankings[c,j]
                resp_matches[indptr[d]-1+a] = i
                prop_matches[i] = j
                prop_matches[c] = -1
            end
        end
        prop_next_to_propose[i] += 1
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
function my_deferred_acceptance(prop_prefs::Vector{Vector{Int}},
                                resp_prefs::Vector{Vector{Int}})
    caps = ones(Int, length(resp_prefs))
    prop_matches, resp_matches, indptr =
        my_deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end