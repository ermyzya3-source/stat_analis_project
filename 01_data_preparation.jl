using CSV
using DataFrames
using Statistics

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

# Формирование ITT-популяции
itt_data = filter(:ITTFL => ==("ДА"), data)

println()
println("Количество пациентов в ITT: ", nrow(itt_data))

# Выбираем переменные, которые понадобятся для анализа
analysis_data = select(
    itt_data,
    :SUBJID,
    :TRT01P,
    :TRT01A,
    :PPROTFL,
    :V1_SEX,
    :V1_AGE,
    :V1_HEIGHT,
    :V1_WEIGHT,
    :V1_BMI,
    :V1_NIHSS_VALUE,
    :V1_BARTHEL_VALUE,
    :V1_MRS_VALUE,
    :V3_MRS_GOOD,
    :V4_MRS_GOOD
)

println("Количество строк аналитического датасета: ", nrow(analysis_data))
println("Количество столбцов аналитического датасета: ", ncol(analysis_data))

# Кодирование категориальных переменных
analysis_data.TRT_CODE =
    ifelse.(analysis_data.TRT01P .== "Препарат", 1, 0)

analysis_data.SEX_CODE =
    ifelse.(analysis_data.V1_SEX .== "М", 1, 0)

# Стандартизация непрерывных переменных
analysis_data.AGE_Z =
    (analysis_data.V1_AGE .- mean(analysis_data.V1_AGE)) ./ std(analysis_data.V1_AGE)

analysis_data.HEIGHT_Z =
    (analysis_data.V1_HEIGHT .- mean(analysis_data.V1_HEIGHT)) ./ std(analysis_data.V1_HEIGHT)

analysis_data.WEIGHT_Z =
    (analysis_data.V1_WEIGHT .- mean(analysis_data.V1_WEIGHT)) ./ std(analysis_data.V1_WEIGHT)

analysis_data.BMI_Z =
    (analysis_data.V1_BMI .- mean(analysis_data.V1_BMI)) ./ std(analysis_data.V1_BMI)

println()
println("ПРОПУЩЕННЫЕ ЗНАЧЕНИЯ")

for column in names(analysis_data)
    missing_count = count(ismissing, analysis_data[!, column])

    if missing_count > 0
        println(column, ": ", missing_count)
    end
end

analysis_path = joinpath(@__DIR__, "analysis_dataset.csv")
CSV.write(analysis_path, analysis_data)

println()
println("Аналитический датасет сохранен:")
println(analysis_path)

nothing
