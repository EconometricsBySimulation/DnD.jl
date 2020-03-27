module DnD

Pkg.activate(".")
using CSV
using DataFrames

creatures = CSV.read("data_d20datascience\\src\\creatures.csv")
fighter   = CSV.read("data_d20datascience\\src\\fighter.csv")
wizard    = CSV.read("data_d20datascience\\src\\wizard.csv")

teamA = creatures[Integer.(round.(rand(1)*300 .+ (1:4))),:]
teamB = creatures[Integer.(round.(rand(1)*300 .+ (1:4))),:]


# function combatsim(teamA, teamB)

  teamA.team = 1
  teamB.team = 2
  teams = vcat(teamA, teamB)

  println("Team 1\n  ", join(teamA.name, "\n  "))
  println("Team 2\n  ", join(teamB.name, "\n  "))

  teams.currentHP = copy(teams.hp)
  teams.order = rand(size(teams,1)) .* 20 .+ 1 + teams.init
  sort!(teams, :order, rev = true)

  team1count = size(teamA, 1)
  team2count = size(teamB, 1)

  currentround = 0

  while ((team1count > 0) & (team2count > 0))
    global currentround
    println(currentround)
    currentround += 1
    # Loop through each creature
    for i in 1:size(teams, 1)
        # If current creature HP is 0 skip
      (teams.currentHP[i] <= 0) && continue

      currentteam =  teams.team[i]
      otherteam = teams.team .!== currentteam

      for j in 1:teams.att_num[i]
        global team1count, team2count

        potential = findall(otherteam .& (teams.currentHP .> 0) .== 1)

        target = potential[1]

        attack_roll  = ceil.(rand(1)*20)[1] |> Integer
        attack_value = attack_roll + teams.hit_mod[i]

        hit = (teams.ac[target] <= attack_value)

        (attack_roll == 20) && (hit == true)
        (attack_roll == 1) && (hit == false)

        hit && (teams.currentHP[target] -= teams.dam_avg[i])

        team1count = sum(teams.currentHP[teams.team .== 1, :] .> 0)
        team2count = sum(teams.currentHP[teams.team .== 2, :] .> 0)

        ((team1count==0) | (team2count==0)) && break

      end

      ((team1count==0) | (team2count==0)) && break
    end

    (team1count==0) && (println("Team 2 wins!"); break)
    (team2count==0) && (println("Team 1 wins!"); break)

    (currentround > 10) && break

  end


# end

end # module
