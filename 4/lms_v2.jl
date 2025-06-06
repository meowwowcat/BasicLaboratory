# 最小二乗法の計算とそれを用いた直線の表示をするコードです.
# コードa けずに

using CSV
using Plots
using DataFrames
using Printf



λ = 5.89*10^(-4)

# データの読み込み

df1 = CSV.read("data/data1.csv", DataFrame, delim=" ", ignorerepeated=true)
df2 = CSV.read("data/data2.csv",DataFrame)

x = df1[:, 1] #number1~15
a_r = df1[:, 2] #r_r
a_l = df1[:,3] #r_l
err = df2[:,1] # 誤差データ（10個）

N =length(x)
N_err = length(err)

#l2

l = a_r - a_l
y = l .* l

# 標準偏差σ_a
ave_err = sum(err) / N_err
d_err = err .- ave_err
σ_a = sqrt(sum(d_err .^2) / (N_err -1))

#標準誤差σ_i
σ_i = 2 .* sqrt(2) .*σ_a .* l

σ2_i = σ_i .^2



# 最小二乗法
sum_1_σ2 = sum(1 ./ σ2_i) 
sum_x_σ2 = sum(x ./ σ2_i)
sum_y_σ2 = sum(y ./ σ2_i)
sum_x2_σ2 = sum( (x .^2) ./ σ2_i)
sum_y2_σ2 = sum( (y .^2) ./ σ2_i)
sum_xy_σ2 = sum((x .* y) ./ σ2_i)

# A,Bの計算

denominator = sum_x2_σ2 * sum_1_σ2 - sum_x_σ2^2

A = (sum_xy_σ2 * sum_1_σ2 - sum_x_σ2 * sum_y_σ2) / denominator
B = (sum_x2_σ2 * sum_y_σ2 - sum_x_σ2 * sum_xy_σ2) / denominator
δA = sqrt( (sum_1_σ2) / denominator)


R = A /(4 * λ)
R_δ = δA / (4 * λ)
# σ'

sigma = y .- A .* x .- B 

sig = sigma - σ_i

println("A = $A")
println("δA = $δA")
println("B = $B")
println("R = $R ± $R_δ")

open("data/data3.txt","w") do io
    println(io, "A_t = $A ± $δA")
    println(io, "B = $B")
    println(io, "R = $R")
    println(io, "R_t = $R ± $R_δ")
end
#sugukesu
open("data/data4.txt","w") do io
    println(io, "A = $A")
    println(io, "  δA = $δA  ")
    println(io, " R = $R")
    println(io, "δR = $R_δ")

    println(io, "sigma = $sigma")

end
# csvの作成
df_3 = DataFrame(x = x, σ_i = σ_i)
CSV.write("output/out_1.csv", df_3)

df_3 = DataFrame(sig = sig)
CSV.write("output/out_2.csv", df_3)

#グラフのプロット

plt = plot(
    x,y,
    xlabel="Number:m",
    ylabel="\$l_m^2\$[(mm)\$^2\$]",
    label="Mesured Line",
    marker=:circle
    
)
plot!(x, A .* x .+ B, label="Fit Line", lw=2)

savefig( "figures/fig.pdf")
savefig( "figures/fig.png")
