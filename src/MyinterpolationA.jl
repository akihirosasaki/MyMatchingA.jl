module MyinterpolationA
export myinterpolationA

function myinterpolationA(grid, vals)
    function func(x)
        if x < grid[1] || x > grid[length(grid)]
            return "error"
        end
        
        
        num_2 = searchsortedfirst(grid, x)
        if num_2 == 1
            return vals[num_2]
        end
        
        num_1 = num_2 - 1
        x_1 = grid[num_1]
        x_2 = grid[num_2]
        y_1 = vals[num_1]
        y_2 = vals[num_2]
        
        y = ((y_2- y_1)/(x_2 - x_1))*(x - x_1) + y_1
        return y
    end
end

end
