using CSV
using DataFrames
using Statistics
using StatsPlots

# Загрузка данных
data_path = joinpath(@__DIR__, "analysis_dataset.csv")
data = CSV.read(data_path, DataFrame)

# Разделение по группам лечения
drug = filter(:TRT01P => ==("Препарат"), data)
placebo = filter(:TRT01P => ==("Плацебо"), data)

# Папка для сохранения графиков
figures_path = joinpath(@__DIR__, "figures")
mkpath(figures_path)


# 1. Гистограмма возраста
p1 = histogram(
    data.V1_AGE,
    group = data.TRT01P,
    bins = 12,
    alpha = 0.55,
    xlabel = "Возраст, лет",
    ylabel = "Число пациентов",
    title = "Распределение возраста по группам",
    legend = :topright
)

savefig(p1, joinpath(figures_path, "age_histogram.png"))


# 2. Boxplot BMI
p2 = @df data boxplot(
    :TRT01P,
    :V1_BMI,
    xlabel = "Группа лечения",
    ylabel = "ИМТ, кг/м²",
    title = "Распределение ИМТ по группам",
    legend = false
)

savefig(p2, joinpath(figures_path, "bmi_boxplot.png"))


# 3. Boxplot NIHSS
p3 = @df data boxplot(
    :TRT01P,
    :V1_NIHSS_VALUE,
    xlabel = "Группа лечения",
    ylabel = "NIHSS, баллы",
    title = "Исходные значения NIHSS по группам",
    legend = false
)

savefig(p3, joinpath(figures_path, "nihss_boxplot.png"))


# 4. Распределение по полу

drug_sex = [
    count(==("Ж"), drug.V1_SEX),
    count(==("М"), drug.V1_SEX)
] ./ nrow(drug) .* 100

placebo_sex = [
    count(==("Ж"), placebo.V1_SEX),
    count(==("М"), placebo.V1_SEX)
] ./ nrow(placebo) .* 100

sex_labels = ["Ж", "М"]

p4 = groupedbar(
    sex_labels,
    hcat(drug_sex, placebo_sex),
    bar_position = :dodge,
    xlabel = "Пол",
    ylabel = "Доля пациентов, %",
    title = "Распределение пациентов по полу",
    label = ["Препарат" "Плацебо"]
)

savefig(p4, joinpath(figures_path, "sex_barplot.png"))


# 5. Распределение исходного mRS

mrs_scores = 0:4

drug_mrs_valid =
    collect(skipmissing(drug.V1_MRS_VALUE))

placebo_mrs_valid =
    collect(skipmissing(placebo.V1_MRS_VALUE))

drug_mrs = [
    count(==(score), drug_mrs_valid)
    for score in mrs_scores
]

placebo_mrs = [
    count(==(score), placebo_mrs_valid)
    for score in mrs_scores
]

drug_mrs_pct =
    drug_mrs ./ sum(drug_mrs) .* 100

placebo_mrs_pct =
    placebo_mrs ./ sum(placebo_mrs) .* 100

p5 = groupedbar(
    string.(mrs_scores),
    hcat(drug_mrs_pct, placebo_mrs_pct),
    bar_position = :dodge,
    xlabel = "mRS, баллы",
    ylabel = "Доля пациентов, %",
    title = "Распределение исходных значений mRS",
    label = ["Препарат" "Плацебо"]
)

savefig(p5, joinpath(figures_path, "mrs_barplot.png"))

println("Графики сохранены в папке figures")

nothing