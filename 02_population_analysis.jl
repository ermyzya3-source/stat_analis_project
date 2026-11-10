using CSV
using DataFrames
using Statistics
using HypothesisTests
using Distributions

# Загрузка аналитического датасета
data_path = joinpath(@__DIR__, "analysis_dataset.csv")
data = CSV.read(data_path, DataFrame)

# Разделение пациентов по группам
drug = filter(:TRT01P => ==("Препарат"), data)
placebo = filter(:TRT01P => ==("Плацебо"), data)

println("Всего пациентов: ", nrow(data))
println("Препарат: ", nrow(drug))
println("Плацебо: ", nrow(placebo))


# Функция описательной статистики
function descriptive_stats(x)

    values = collect(skipmissing(x))

    n = length(values)
    m = mean(values)
    s = std(values)
    med = median(values)

    q1 = quantile(values, 0.25)
    q3 = quantile(values, 0.75)

    min_value = minimum(values)
    max_value = maximum(values)

    t_crit = quantile(TDist(n - 1), 0.975)
    margin = t_crit * s / sqrt(n)

    return (
        N = n,
        Mean = m,
        SD = s,
        Median = med,
        Q1 = q1,
        Q3 = q3,
        Min = min_value,
        Max = max_value,
        CI_low = m - margin,
        CI_high = m + margin
    )
end


# Описательная статистика
variables = [
    :V1_AGE,
    :V1_HEIGHT,
    :V1_WEIGHT,
    :V1_BMI,
    :V1_NIHSS_VALUE,
    :V1_BARTHEL_VALUE,
    :V1_MRS_VALUE
]

println()
println("ОПИСАТЕЛЬНАЯ СТАТИСТИКА")

for variable in variables

    println()
    println(variable)

    println("Все пациенты:")
    println(descriptive_stats(data[!, variable]))

    println("Препарат:")
    println(descriptive_stats(drug[!, variable]))

    println("Плацебо:")
    println(descriptive_stats(placebo[!, variable]))
end


# Сравнение количественных переменных
continuous_variables = [
    :V1_AGE,
    :V1_HEIGHT,
    :V1_WEIGHT,
    :V1_BMI
]

println()
println("T-ТЕСТ УЭЛЧА")

for variable in continuous_variables

    drug_values =
        collect(skipmissing(drug[!, variable]))

    placebo_values =
        collect(skipmissing(placebo[!, variable]))

    test = UnequalVarianceTTest(
        drug_values,
        placebo_values
    )

    println()
    println(variable)
    println("p = ", pvalue(test))
end


# Сравнение шкальных переменных
ordinal_variables = [
    :V1_NIHSS_VALUE,
    :V1_BARTHEL_VALUE,
    :V1_MRS_VALUE
]

println()
println("КРИТЕРИЙ МАННА–УИТНИ")

for variable in ordinal_variables

    drug_values =
        collect(skipmissing(drug[!, variable]))

    placebo_values =
        collect(skipmissing(placebo[!, variable]))

    test = MannWhitneyUTest(
        drug_values,
        placebo_values;
        method = :approximate
    )

    println()
    println(variable)
    println("p = ", pvalue(test))
end


# Таблица сопряженности по полу
female_drug = count(==("Ж"), drug.V1_SEX)
male_drug = count(==("М"), drug.V1_SEX)

female_placebo = count(==("Ж"), placebo.V1_SEX)
male_placebo = count(==("М"), placebo.V1_SEX)

sex_table = [
    female_drug female_placebo;
    male_drug   male_placebo
]

println()
println("ТАБЛИЦА СОПРЯЖЕННОСТИ: ПОЛ × ГРУППА")
println(sex_table)

sex_test = ChisqTest(sex_table)

println()
println("КРИТЕРИЙ ХИ-КВАДРАТ")
println("p = ", pvalue(sex_test))

nothing