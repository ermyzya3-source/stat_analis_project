using CSV
using DataFrames

# Пути к файлам
data_path = joinpath(@__DIR__, "result_data_n_3.csv")
dictionary_path = joinpath(@__DIR__, "field_dictionary.csv")

# Загрузка данных
data = CSV.read(data_path, DataFrame)
dictionary = CSV.read(dictionary_path, DataFrame; delim=';')


# ПЕРВИЧНАЯ ПРОВЕРКА ДАННЫХ
println("ОСНОВНОЙ ДАТАСЕТ")
println("Количество строк: ", nrow(data))
println("Количество столбцов: ", ncol(data))
println("СЛОВАРЬ ПЕРЕМЕННЫХ")
println("Количество строк: ", nrow(dictionary))
println("Количество столбцов: ", ncol(dictionary))

println()
println(" ПЕРВЫЕ 5 СТРОК ОСНОВНОГО ДАТАСЕТА")
display(first(data, 5))

println()
println("ПЕРВЫЕ 5 СТРОК СЛОВАРЯ")
display(first(dictionary, 5))

println()

println("Количество уникальных пациентов SUBJID: ",
        length(unique(data.SUBJID)))

println()
println("ITT-популяция:")
display(combine(groupby(data, :ITTFL), nrow => :N))

println()
println("PP-популяция:")
display(combine(groupby(data, :PPROTFL), nrow => :N))

println()
println("Распределение по группам лечения:")
display(combine(groupby(data, :TRT01P), nrow => :N))

println()
println("Распределение по полу:")
display(combine(groupby(data, :V1_SEX), nrow => :N))

nothing
