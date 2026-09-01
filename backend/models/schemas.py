from pydantic import BaseModel, Field
from typing import Optional, List, Any
from enum import Enum


class DataType(str, Enum):
    SIMPLE = "simple"
    GROUPED = "grouped"
    CLASS_INTERVAL = "class_interval"
    BIVARIATE = "bivariate"


class DataNature(str, Enum):
    DISCRETE = "discrete"
    CONTINUOUS = "continuous"


class DataLevel(str, Enum):
    NOMINAL = "nominal"
    ORDINAL = "ordinal"
    INTERVAL = "interval"
    RATIO = "ratio"


class SimpleDataInput(BaseModel):
    values: List[float] = Field(..., description="Liste des valeurs numériques")
    variable_name: Optional[str] = Field("Variable", description="Nom de la variable")
    level: DataLevel = Field(DataLevel.RATIO, description="Niveau de mesure")
    data_nature: Optional[DataNature] = Field(DataNature.CONTINUOUS, description="Nature des données: discrete ou continuous")


class GroupedDataInput(BaseModel):
    values: List[float] = Field(..., description="Liste des valeurs (xᵢ)")
    frequencies: List[int] = Field(..., description="Liste des effectifs (nᵢ)")
    variable_name: Optional[str] = Field("Variable", description="Nom de la variable")
    data_nature: Optional[DataNature] = Field(DataNature.CONTINUOUS, description="Nature des données: discrete ou continuous")


class ClassIntervalDataInput(BaseModel):
    lower_bounds: List[float] = Field(..., description="Bornes inférieures")
    upper_bounds: List[float] = Field(..., description="Bornes supérieures")
    frequencies: List[int] = Field(..., description="Effectifs par classe")
    variable_name: Optional[str] = Field("Variable", description="Nom de la variable")
    interval_type: str = Field("[a;b[", description="Type d'intervalle")
    data_nature: Optional[DataNature] = Field(DataNature.CONTINUOUS, description="Nature des données: discrete ou continuous")


class BivariateDataInput(BaseModel):
    x: List[float] = Field(..., description="Valeurs de X")
    y: List[float] = Field(..., description="Valeurs de Y")
    x_name: Optional[str] = Field("X", description="Nom variable X")
    y_name: Optional[str] = Field("Y", description="Nom variable Y")
    data_nature: Optional[DataNature] = Field(DataNature.CONTINUOUS, description="Nature des données: discrete ou continuous")


class DescriptiveStatsResult(BaseModel):
    n: int
    mean: float
    median: float
    mode: Any
    variance: float
    std_dev: float
    range: float
    cv: float
    q1: float
    q2: float
    q3: float
    iqr: float
    skewness: float
    kurtosis: float
    min_val: float
    max_val: float
    sum: float
    sem: float
    outliers: List[float]
    is_normal: bool = False
    normality_p_value: float = 0.0
    data_type: str = "simple"
    data_nature: str = "continuous"


class BivariateStatsResult(BaseModel):
    n: int
    mean_x: float
    mean_y: float
    std_x: float
    std_y: float
    covariance: float
    pearson_r: float
    r_squared: float
    regression_slope: float
    regression_intercept: float
    interpretation: str


class HypothesisTestInput(BaseModel):
    values: List[float]
    test_type: str = Field(..., description="one_sample_t, two_sample_t, chi_square")
    reference_value: Optional[float] = None
    sample2: Optional[List[float]] = None
    observed: Optional[List[float]] = None
    expected: Optional[List[float]] = None
    alpha: float = Field(0.05, description="Seuil de signification")


class HypothesisTestResult(BaseModel):
    test_name: str
    statistic: float
    p_value: float
    critical_value: float
    degrees_of_freedom: Optional[int]
    reject_null: bool
    interpretation: str
    confidence_level: float


class ConfidenceIntervalResult(BaseModel):
    level: float
    lower: float
    upper: float
    margin_of_error: float
    interpretation: str


class ProbabilityInput(BaseModel):
    law: str = Field(..., description="normal, uniform, binomial, poisson, bernoulli, chi2")
    params: dict = Field(..., description="Paramètres de la loi")
    x: Optional[float] = Field(None, description="Valeur pour P(X=x) ou P(X<=x)")
    x_min: Optional[float] = Field(None, description="Borne inférieure intervalle")
    x_max: Optional[float] = Field(None, description="Borne supérieure intervalle")


class ProbabilityResult(BaseModel):
    law: str
    params: dict
    p_equal: Optional[float] = None
    p_less_equal: Optional[float] = None
    p_interval: Optional[float] = None
    mean: float
    variance: float
    std_dev: float
    interpretation: str


class ChartInput(BaseModel):
    chart_type: str = Field(..., description="histogram, boxplot, bar, pie, scatter, line, ogive, normal_curve, violin, qq_plot")
    data_type: DataType
    values: Optional[List[float]] = None
    frequencies: Optional[List[int]] = None
    lower_bounds: Optional[List[float]] = None
    upper_bounds: Optional[List[float]] = None
    x: Optional[List[float]] = None
    y: Optional[List[float]] = None
    title: Optional[str] = None
    variable_name: Optional[str] = "Variable"
    data_nature: Optional[DataNature] = Field(DataNature.CONTINUOUS, description="Nature des données: discrete ou continuous")


class ChartResult(BaseModel):
    image_base64: str
    chart_type: str
    title: str


class PDFExportInput(BaseModel):
    data_type: DataType
    values: Optional[List[float]] = None
    frequencies: Optional[List[int]] = None
    lower_bounds: Optional[List[float]] = None
    upper_bounds: Optional[List[float]] = None
    x: Optional[List[float]] = None
    y: Optional[List[float]] = None
    variable_name: Optional[str] = "Variable"
    data_nature: Optional[str] = "continuous"
    include_descriptive: bool = True
    include_charts: bool = True
    include_interpretation: bool = True
    title: Optional[str] = "Rapport statistique DataMind"


class AnalysisHistoryItem(BaseModel):
    id: str
    data_type: str
    variable_name: str
    created_at: str
    summary: dict
