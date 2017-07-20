module MyMatchingA
export my_deferred_acceptance

#多対多のケース
function my_deferred_acceptance(m_prefs::Vector{Vector{Int}},f_prefs::Vector{Vector{Int}},caps1::Vector{Int},caps2::Vector{Int})
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
        
        
        prop_matches, resp_matches, indptr1, indptr2 = my_deferred_acceptance(prop_prefs, resp_prefs, caps1, caps2)

        return prop_matches,resp_matches,indptr1,indptr2

end

#多対一のケース
function my_deferred_acceptance(m_prefs::Vector{Vector{Int}},f_prefs::Vector{Vector{Int}},caps::Vector{Int})
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

        caps1 = ones(Int, size(prep_prefs, 1))
        caps2 = caps

        prop_matches, resp_matches, indptr1, indptr2 = my_deferred_acceptance(prop_prefs, resp_prefs, caps1, caps2)

        return prop_matches,resp_matches,indptr1,indptr2

end


function my_deferred_acceptance(m_prefs::Vector{Vector{Int}},f_prefs::Vector{Vector{Int}})
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

        caps1 = ones(Int, size(prep_prefs, 1))
        caps2 = ones(Int, size(resp_prefs, 1))
        prop_matches, resp_matches, indptr1, indptr2 =
            my_deferred_acceptance(prop_prefs, resp_prefs, caps1, caps2)
        return prop_matches, resp_matches
end

# 多対多のケース
function my_deferred_acceptance(prop_prefs::Matrix{Int}, resp_prefs::Matrix{Int}, caps1::Vector{Int}, caps2::Vector{Int})
        m = size(prop_prefs, 1)
        n = size(resp_prefs, 1)

        prop_matches = fill(-1, m)

        prop_next_to_propose = ones(Int64, m)
        L = sum(caps2)
        resp_matches = zeros(Int64, L)

        indptr1 = Array{Int}(m+1)
        indptr1[1] = 1
        for i in 1:m
            indptr1[i+1] = indptr1[i] + caps1[i]
        end  

        indptr2 = Array{Int}(n+1)
        indptr2[1] = 1
        for i in 1:n
            indptr2[i+1] = indptr2[i] + caps2[i]
        end


        resp_rankings = (m+1)*ones(Int, m, n)    

        for j in 1:n       
           for i in 1:length(resp_prefs[j,:])
               b = length(resp_prefs[j,:])            
               a = resp_prefs[j,i]
                if a == 0
                    continue
                end
               resp_rankings[a,j] = i
           end
        end

        q = resp_rankings
    
        while true
            h = get_single(prop_matches)
            if h == 0
                break
            end
            i = searchsortedlast(indptr1, h)
            if prop_next_to_propose[i] > length(prop_prefs[i,:])
                c = length(prop_prefs[i,:])
                prop_matches[i] = 0
                continue
            end        


            #学生iが入りたい大学jを探す．
            j = prop_prefs[i,prop_next_to_propose[i]]
            if j == 0
                prop_matches[i] = 0
                continue
            end

            #大学jのリストを探す
            #要修正？
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
            prop_next_to_propose[h] += 1
        end

        return prop_matches, resp_matches, indptr1, indptr2    
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


#多対一のケース
function my_deferred_acceptance(prop_prefs::Matrix{Int},resp_prefs::Matrix{Int}, caps::Vector{Int})
        caps1 = ones(Int, size(prep_prefs, 1))
        caps2 = caps
        prop_matches, resp_matches, indptr1, indptr2 =
            my_deferred_acceptance(prop_prefs, resp_prefs, caps1, caps2)
        return prop_matches, resp_matches
end



# 一対一のケース
function my_deferred_acceptance(prop_prefs::Matrix{Int},resp_prefs::Matrix{Int})
        caps1 = ones(Int, size(prep_prefs, 1))
        caps2 = ones(Int, size(resp_prefs, 1))
        prop_matches, resp_matches, indptr1, indptr2 =
            my_deferred_acceptance(prop_prefs, resp_prefs, caps1, caps2)
        return prop_matches, resp_matches
end

end