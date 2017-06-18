module MyMatchingA
export my_deferred_acceptance

function my_deferred_acceptance(boys_prefs, girls_prefs)
    m = size(boys_prefs, 1)
    n = size(girls_prefs, 1)
    #その男性が婚約している女性(リストが尽きた独身=0,リストが尽きてない独身=-1)
    #boys_partners[1] = 2; 男性1は女性2と婚約している．
    boys_partners = fill(-1, m)
    
    boys_next_to_propose = ones(Int, m)
    
    girls_partners = zeros(Int, n)
    
    girls_rankings = (m+1)*ones(Int, m, n)    
    
    for j in 1:n
       for i in 1:length(girls_prefs[j])
            girls_rankings[girls_prefs[j][i]][j] = i
        end
    end
    
    
    while true
        i = get_single(boys_partners)
        if i == 0
            break
        end
        if boys_next_to_propose[i] > length(boys_prefs[i])
            boys_partners[i] = 0
            continue
        end

        #男性iが好きな女性jを探す．
        j = boys_prefs[i][boys_next_to_propose[i]]

        #女性jが婚約している相手pを探す．
        p = girls_partners[j]

        #女性jが独身なら婚約する．
        if p == 0 && girls_rankings[i][j] < m+1
            girls_partners[j] = i
            boys_partners[i] = j

        #女性jが婚約している場合
        else
        #女性jがiの方が好きなら，婚約する．
            if girls_rankings[i][j] < girls_rankings[p][j]
                girls_partners[j] = i
                boys_partners[i] = j
                boys_partners[p] = -1

            end
        end
        boys_next_to_propose[i] += 1
    end
    
    return boys_partners, girls_partners    
end

#独身の男性を返す．(存在しなければ0)
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
