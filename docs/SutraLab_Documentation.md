# SutraLab Documentation

> **See also:** [README](../README.md) for a quick-start overview.

---

## Table of Contents

**English**
1. [Overview](#1-overview)
2. [Requirements & Setup](#2-requirements--setup)
3. [Directory Structure](#3-directory-structure)
4. [Quick Start](#4-quick-start)
5. [Core Read Functions](#5-core-read-functions)
6. [Object-Oriented Interface](#6-object-oriented-interface)
7. [Supported Mesh Types](#7-supported-mesh-types)
8. [Soil Property Models](#8-soil-property-models)
9. [Visualization & Example Cases](#9-visualization--example-cases)
10. [Coding Conventions](#10-coding-conventions)

**中文**
1. [概述](#1-概述)
2. [环境要求与安装](#2-环境要求与安装)
3. [目录结构](#3-目录结构)
4. [快速入门](#4-快速入门)
5. [核心读取函数](#5-核心读取函数)
6. [面向对象接口](#6-面向对象接口)
7. [支持的网格类型](#7-支持的网格类型)
8. [土壤特性模型](#8-土壤特性模型)
9. [可视化与示例案例](#9-可视化与示例案例)
10. [代码规范](#10-代码规范)

---

# English

---

## 1. Overview

**SutraLab** is a MATLAB post-processing toolkit for [USGS SUTRA](https://water.usgs.gov/ogw/sutra/) (Saturated-Unsaturated TRAnsport), a finite-element simulator for fluid flow and solute or energy transport in saturated–unsaturated porous media.

SutraLab provides:
- Parsers for all major SUTRA output and input file formats (`.NOD`, `.ELE`, `.BCOP`, `.BCOF`, `.FIL`, `.INP`)
- Object-oriented wrappers (`nodObj`, `eleObj`, `bcofObj`, `bcopObj`) for convenient data access and matrix conversion
- A library of constitutive models: soil water characteristic curves (SWCC), relative permeability functions, and adsorption isotherms
- Ready-to-run benchmark examples (Henry saltwater intrusion, Island freshwater lens) with visualization scripts

---

## 2. Requirements & Setup

- **MATLAB** R2018b or later (some plotting functions use `sgtitle` from R2018b)
- No additional toolboxes are required for core I/O functions
- Optional: Statistics and Machine Learning Toolbox (for certain analysis scripts)

### Adding SutraLab to the MATLAB path

Navigate to the repository root in MATLAB and run:

```matlab
run('path_to_SutraLab/mfiles/slsetpath.m')
```

This adds all necessary subdirectories to the MATLAB path for the current session. To make the path permanent, add this line to your `startup.m`.

---

## 3. Directory Structure

```
SutraLab/
├── README.md                          # Quick-start overview
├── docs/
│   └── SutraLab_Documentation.md     # This file — full documentation
├── mfiles/                            # Core library
│   ├── slsetpath.m                    # Path setup script
│   ├── SutraLab.m                     # Entry point
│   ├── etc/                           # Internal parsing utilities
│   │   ├── getNextLine.m
│   │   ├── getNext.m / getProp.m / getWord.m
│   │   ├── getOutputLabelName.m
│   │   └── ...
│   ├── read/                          # I/O functions and OOP wrappers
│   │   ├── readNOD.m                  # Read .NOD nodewise results
│   │   ├── readNOD_Ms.m               # Read .NOD (multi-source variant)
│   │   ├── readELE.m                  # Read .ELE element results
│   │   ├── readBCOP.m                 # Read .BCOP pressure BC output
│   │   ├── readBCOF.m                 # Read .BCOF fluid source output
│   │   ├── readFIL.m                  # Read SUTRA.FIL file list
│   │   ├── readINP.m                  # Read .INP input file (mesh info)
│   │   ├── @nodObj/                   # OOP wrapper for NOD data
│   │   ├── @eleObj/                   # OOP wrapper for ELE data
│   │   ├── @bcofObj/                  # OOP wrapper for BCOF data
│   │   ├── @bcopObj/                  # OOP wrapper for BCOP data
│   │   └── @bcouObj/                  # OOP wrapper for BCOU data
│   ├── misc/                          # Constitutive models
│   │   ├── @swccObj/                  # Soil water characteristic curve object
│   │   ├── SWCC_Fayer1995WRR.m
│   │   ├── RelativeK_Mualem1976.m
│   │   ├── RelativeK_VanGenuchten1980.m
│   │   ├── FilmRelativeK_Tokunaga2009WRR.m
│   │   ├── FilmRelativeK_Lebeau2010WRR.m
│   │   ├── adsorption_freundlich.m
│   │   └── adsorption_langmuir.m
│   ├── sutraset/                      # SUTRASET-specific (ET)
│   │   └── @etObj/
│   └── @inpObj/ @icsObj/ @bcsObj/ @filObj/   # Input file objects
├── example/
│   ├── SUTRA_examples/
│   │   └── 2D/
│   │       ├── Henry/                 # Henry saltwater intrusion benchmark
│   │       └── Island2D/              # Island freshwater lens benchmark
│   ├── plot_swcc_kr_carsel1988/       # SWCC/Kr plots for Carsel (1988) soils
│   ├── plot_swcc_kr_marsh/            # SWCC/Kr plots for Marsh (2012) soils
│   ├── Sutra_adsorption/              # Adsorption model examples
│   └── America_2019_wrr_case1n_mesh_generation/   # WRR 2019 field case
```

---

## 4. Quick Start

**Step 1 — Set up the path**
```matlab
run('path_to_SutraLab/mfiles/slsetpath.m')
```

**Step 2 — Navigate to your SUTRA simulation directory** (where `SUTRA.FIL` is located):
```matlab
cd('path_to_your_simulation')
```

**Step 3 — Read simulation files**
```matlab
fil  = readFIL;                  % reads SUTRA.FIL → basename
inp  = inpObj(fil.basename);     % mesh parameters from .INP
nod  = readNOD(fil.basename);    % nodewise results from .NOD
ele  = readELE(fil.basename);    % element velocity from .ELE
bcop = readBCOP(fil.basename);   % specified-pressure BC output
bcof = readBCOF(fil.basename);   % fluid source/sink output
```

**Step 4 — Access data**
```matlab
% Find column indices by label
c_idx = strcmp(nod(1).label, 'Concentration');
x_idx = strcmp(nod(1).label, 'X');
y_idx = strcmp(nod(1).label, 'Y');

% Reshape 1D array into 2D spatial matrix (2-D REGULAR mesh)
c_matrix = reshape(nod(end).terms{c_idx}, [inp.nn1, inp.nn2]);
x_matrix = reshape(nod(1).terms{x_idx},   [inp.nn1, inp.nn2]);
y_matrix = reshape(nod(1).terms{y_idx},   [inp.nn1, inp.nn2]);

% Plot
contourf(x_matrix, y_matrix, c_matrix);
colormap(jet); colorbar;
xlabel('x (m)'); ylabel('y (m)');
```

---

## 5. Core Read Functions

All read functions follow the same calling convention:
```matlab
[data, header] = readXXX(basename, 'outputnumber', N, 'outputfrom', M)
```

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `basename` | string | — | Project name without extension (e.g. `'Henry2D'`) |
| `'outputnumber'` | int | all | Number of time steps to read; negative values read from the end |
| `'outputfrom'` | int | 1 | Starting time step index |

### 5.1 `readNOD` — Nodewise results

```matlab
[nod, nod2] = readNOD(basename)
[nod, nod2] = readNOD(basename, 'outputnumber', 5)    % first 5 steps
[nod, nod2] = readNOD(basename, 'outputnumber', -3)   % last 3 steps
[nod, nod2] = readNOD(basename, 'outputfrom', 10, 'outputnumber', 5)
```

**Returns:**
- `nod` — struct array `(1 × N_steps)`. Each element has:
  - `.itout` — time step index
  - `.tout` — simulation time (s)
  - `.durn` — step duration (s)
  - `.label` — cell array of output variable names (e.g. `{'Node','X','Y','Pressure','Concentration','Saturation'}`)
  - `.terms` — cell array of data vectors, one per label column
- `nod2` — header struct with mesh metadata:
  - `.nn`, `.ne`, `.nn1`, `.nn2` (`.nn3` for 3-D) — mesh dimensions
  - `.mshtyp` — `{dimension, type}` e.g. `{'2-D','REGULAR'}`
  - `.ktprn` — total number of outputs in file
  - `.tt`, `.itt` — time and step index for each stored output

### 5.2 `readELE` — Element velocity results

```matlab
[ele, ele2] = readELE(basename)
[ele, ele2] = readELE(basename, 'outputnumber', 10)
```

**Returns:**
- `ele` — struct array `(1 × N_steps)`. Each element has:
  - `.itout`, `.tout`, `.durn` — time information
  - `.label` — e.g. `{'Element','X origin','Y origin','X velocity','Y velocity'}`
  - `.terms` — data vectors for each label
- `ele2` — header struct with mesh info (`.ne`, `.nn`, `.mshtyp`, etc.)

### 5.3 `readBCOP` — Pressure boundary condition output

```matlab
[bcop, bcop2] = readBCOP(basename)
```

Contains nodal results at specified-pressure boundary nodes. Header provides `.npbc` (number of pressure BC nodes).

### 5.4 `readBCOF` — Fluid source/sink output

```matlab
[bcof, bcof2] = readBCOF(basename)
```

Contains results at fluid source/sink nodes. Header provides `.nsop`.

### 5.5 `readFIL` — SUTRA file list

```matlab
fil = readFIL         % reads SUTRA.FIL in current directory
fil = readFIL('path/to/SUTRA.FIL')
```

Returns a struct with `.basename` — the project name used for all other read calls.

### 5.6 `readINP` — Input file mesh structure

```matlab
inp2 = readINP(basename)
```

Parses the `.INP` file to extract:
- `.meshtype` — mesh dimension and type
- `.nn`, `.ne`, `.np`, `.nc`, `.nf`, `.ns`, `.no` — Data Set 3 counts
- `.ds22` — element incidence table (Data Set 22); 5 columns for 2-D, 9 for 3-D

---

## 6. Object-Oriented Interface

The OOP wrappers (`nodObj`, `eleObj`, etc.) provide a more ergonomic interface with built-in matrix conversion and averaging methods.

### 6.1 `nodObj`

```matlab
nod = nodObj(basename)
nod = nodObj(basename, 'outputnumber', 10)
nod = nodObj(basename, 'mtx_transpose', 'yes')   % transpose reshape
```

**Computed index properties** (auto-populated from labels):

| Property | Description |
|----------|-------------|
| `nod.n_idx` | Column index for 'Node' |
| `nod.x_idx` | Column index for 'X' |
| `nod.y_idx` | Column index for 'Y' |
| `nod.z_idx` | Column index for 'Z' |
| `nod.p_idx` | Column index for 'Pressure' |
| `nod.c_idx` | Column index for 'Concentration' |
| `nod.s_idx` | Column index for 'Saturation' |

**Methods:**

| Method | Description |
|--------|-------------|
| `nod.export('c', 'steps', N)` | Export concentration at step N |
| `nod.export('c', 'mtx', 'steps', N)` | Export as 2D matrix |
| `nod.average('c')` | Time-averaged concentration |
| `nod.average('c', 'mtx')` | Time-averaged, as matrix |
| `nod.average('c', 'range', 5:10)` | Average over steps 5–10 |
| `nod.convert_2_mtx(vec)` | Reshape vector to 2D matrix |
| `nod.delete_terms(idx)` | Remove unwanted output columns |

**Option `del_unfinished_end`** (default `'yes'`): automatically removes the last incomplete output if the simulation was interrupted.

### 6.2 `eleObj`

```matlab
ele = eleObj(basename)
ele = eleObj(basename, 'outputnumber', 5)
```

**Computed index properties:**

| Property | Description |
|----------|-------------|
| `ele.e_idx` | 'Element' column |
| `ele.x_idx` | 'X origin' column |
| `ele.y_idx` | 'Y origin' column |
| `ele.vx_idx` | 'X velocity' column |
| `ele.vy_idx` | 'Y velocity' column |
| `ele.vz_idx` | 'Z velocity' column |

**Methods:**

| Method | Description |
|--------|-------------|
| `ele.average('vx')` | Time-averaged x-velocity |
| `ele.average('vx', 'mtx')` | As 2D matrix |
| `ele.convert_2_mtx(vec)` | Reshape to element matrix |

### 6.3 `bcofObj` and `bcopObj`

```matlab
bcof = bcofObj(basename)   % fluid source/sink BC
bcop = bcopObj(basename)   % specified-pressure BC
```

Provide the same `average` method for time-averaging boundary fluxes.

---

## 7. Supported Mesh Types

Both the function-style readers and the OOP wrappers detect mesh type from the `.NOD`/`.ELE` file header and parse dimensions accordingly.

| Dimension | Type | Variables extracted | Notes |
|-----------|------|---------------------|-------|
| 2-D | REGULAR | `nn1`, `nn2`, `nn`, `ne` | Structured rectangular grid |
| 2-D | IRREGULAR | `nn` | Unstructured grid; no dimension split |
| 3-D | REGULAR | `nn1`, `nn2`, `nn3`, `nn`, `ne` | Structured 3D grid |
| 3-D | BLOCKWISE | `nn1`, `nn2`, `nn3`, `nn`, `ne` | Block-structured 3D grid |
| 3-D | LAYERED | `nn1`, `nn2`, `nn3`, `nn`, `ne` | Layer-by-layer 3D grid |

For 2-D REGULAR meshes, data vectors can be reshaped to `[nn1, nn2]` matrices:
```matlab
c_matrix = reshape(nod(t).terms{c_idx}, [inp.nn1, inp.nn2]);
```

For 3-D BLOCKWISE meshes, reshape to `[nn1, nn2, nn3]`:
```matlab
p_cube = reshape(nod(t).terms{p_idx}, [inp.nn1, inp.nn2, inp.nn3]);
```

---

## 8. Soil Property Models

### 8.1 `swccObj` — Soil Water Characteristic Curve

`swccObj` reads a CSV-format parameter file and computes SWCC and relative permeability curves for multiple soil types at once.

**Parameter file format** (comma-delimited, one soil per line):
```
soil_type, swres, alpha, vn, ksat, porosity, psim0, comment, line_type
Sandy_loam, 0.065, 7.5, 1.89, 1.06e-5, 0.41, -50, Carsel1988, -
```

**Usage:**
```matlab
a = swccObj('carsel1988_parameters.dat');
a.psim = -[0:0.01:5, 5:0.1:10, 11:1:100, 200:100:10000]';  % matric potential (m)

% Calculate curves
a.calc_swcc('type', 'fayer1995');
a.calc_relativek('type', 'mualem1976', 'tortuosity', 0.5);
a.calc_relativek('type', 'mualem1976_sw_stretch');
a.calc_relativek('type', 'tokunaga2009');

% Plot
figure; a.plot_swcc('type', 'fayer1995');
figure; a.plot_relativek('type', 'mualem1976');
```

**Available SWCC model:** `'fayer1995'` — Fayer & Simmons (1995) modified van Genuchten

**Available relative permeability models:**

| Model key | Reference | Description |
|-----------|-----------|-------------|
| `'mualem1976'` | Mualem (1976) | Standard capillary bundle model |
| `'mualem1976_sw_stretch'` | — | Mualem with saturation stretch factor |
| `'tokunaga2009'` | Tokunaga (2009) WRR | Film flow model |
| `'lebeau2010'` | Lebeau (2010) WRR | Film flow variant |

### 8.2 Standalone constitutive functions

These functions can be called directly without `swccObj`:

```matlab
sw = SWCC_Fayer1995WRR(psim, alpha, vn, psim0, swres);
kr = RelativeK_Mualem1976(psim, alpha, vn, 'tortuosity', 0.5);
kr = RelativeK_VanGenuchten1980(psim, alpha, vn, swres);
[kfs, kfr] = FilmRelativeK_Tokunaga2009WRR(psim, T, d, por, n);
cs = adsorption_freundlich(c, kf, nf);
cs = adsorption_langmuir(c, kl, sl_max);
```

---

## 9. Visualization & Example Cases

### 9.1 Running an example

Each example under `example/SUTRA_examples/` contains two scripts meant to be run in sequence:

1. **`sl_read.m`** — reads SUTRA output files and creates index variables
2. **`sl_analyze.m`** — reshapes data into matrices and generates plots

```matlab
% In MATLAB, navigate to the example directory:
cd('example/SUTRA_examples/2D/Henry')
run('sl_read.m')
run('sl_analyze.m')
```

### 9.2 Henry Problem (2-D saltwater intrusion)

**Location:** `example/SUTRA_examples/2D/Henry/`

Classic Henry (1964) benchmark problem for variable-density flow. A 2-D cross-section with freshwater inflow on the left and saltwater boundary on the right.

**Plots generated by `sl_analyze.m`:**
- Concentration contour maps at early and late time steps
- X- and Y-velocity contour maps
- Concentration contours overlaid with velocity arrows (`quiver`)
- Saturation maps (full domain and zoomed)

**Key code pattern:**
```matlab
% Read
inp = inpObj('Henry2D');
nod = readNOD('Henry2D');
ele = readELE('Henry2D');

% Build index vectors
c_idx  = strcmp(nod(1).label, 'Concentration');
vx_idx = strcmp(ele(1).label, 'X velocity');

% Reshape to 2D matrix
c_matrix = reshape(nod(end).terms{c_idx}, [inp.nn1, inp.nn2]);

% Plot with velocity arrows
contourf(x_matrix, y_matrix, c_matrix); colormap(jet);
hold on;
quiver(xele, yele, vx*86400, vy*86400, 'w', 'AutoScaleFactor', 3);
```

### 9.3 Island Problem (2-D freshwater lens)

**Location:** `example/SUTRA_examples/2D/Island2D/`

Simulates a freshwater lens on a small island surrounded by seawater. Demonstrates the development of the Ghyben-Herzberg lens over time.

Plots generated follow the same pattern as Henry but show the symmetric lens shape.

### 9.4 SWCC and relative permeability plots

**Location:** `example/plot_swcc_kr_carsel1988/` and `example/plot_swcc_kr_marsh/`

```matlab
cd('example/plot_swcc_kr_carsel1988')
run('process_all.m')   % generates swcc_all.fig and Relative_permeability_all.fig
```

Plots SWCC and Kr curves for 12 Carsel & Parrish (1988) soil texture classes using semi-log axes.

---

## 10. Coding Conventions

1. **Variable names:** Use SUTRA's original variable names where they exist (e.g. `nn`, `ne`, `npbc`, `nsop`)
2. **New names:** Use lowercase with underscores; length does not matter as long as names are self-explanatory (e.g. `del_unfinished_end`, `get_relative_k`)
3. **Indentation:** Use tabs, not spaces
4. **Function style:** New utility functions follow the `varargin` + `getProp`/`getNext` pattern for flexible named arguments
5. **File naming:** Read functions are named `readXXX`; class method files use lowercase with underscores

---
---

# 中文

---

## 1. 概述

**SutraLab** 是一个用于 [USGS SUTRA](https://water.usgs.gov/ogw/sutra/) 的 MATLAB 后处理工具包。SUTRA 是一个有限元数值模拟软件，用于模拟饱和-非饱和多孔介质中的流体流动与溶质/能量传输。

SutraLab 提供以下功能：
- 支持 SUTRA 所有主要输出和输入文件格式的解析器（`.NOD`、`.ELE`、`.BCOP`、`.BCOF`、`.FIL`、`.INP`）
- 面向对象的封装类（`nodObj`、`eleObj`、`bcofObj`、`bcopObj`），提供便捷的数据访问和矩阵转换方法
- 本构模型库：土壤水分特征曲线（SWCC）、相对渗透率函数和吸附等温线
- 可直接运行的基准算例（Henry 盐水入侵问题、Island 淡水透镜体问题）及可视化脚本

---

## 2. 环境要求与安装

- **MATLAB** R2018b 或更高版本（部分绘图函数使用 R2018b 引入的 `sgtitle`）
- 核心 I/O 函数无需额外工具箱
- 可选：Statistics and Machine Learning Toolbox（用于部分分析脚本）

### 将 SutraLab 添加至 MATLAB 路径

在 MATLAB 中导航到仓库根目录，运行：

```matlab
run('path_to_SutraLab/mfiles/slsetpath.m')
```

这将把所有必要子目录添加到当前会话的 MATLAB 路径中。如需永久生效，可将该行添加到 `startup.m` 文件中。

---

## 3. 目录结构

```
SutraLab/
├── README.md                          # 快速入门说明
├── docs/
│   └── SutraLab_Documentation.md     # 本文件 — 完整文档
├── mfiles/                            # 核心库
│   ├── slsetpath.m                    # 路径配置脚本
│   ├── SutraLab.m                     # 入口文件
│   ├── etc/                           # 内部解析工具函数
│   ├── read/                          # I/O 函数及面向对象封装
│   │   ├── readNOD.m                  # 读取节点结果 .NOD
│   │   ├── readNOD_Ms.m               # 读取 .NOD（多源变体）
│   │   ├── readELE.m                  # 读取单元结果 .ELE
│   │   ├── readBCOP.m                 # 读取压力边界输出 .BCOP
│   │   ├── readBCOF.m                 # 读取流量源汇输出 .BCOF
│   │   ├── readFIL.m                  # 读取 SUTRA.FIL 文件列表
│   │   ├── readINP.m                  # 读取输入文件网格信息 .INP
│   │   ├── @nodObj/                   # NOD 数据的面向对象封装
│   │   ├── @eleObj/                   # ELE 数据的面向对象封装
│   │   ├── @bcofObj/                  # BCOF 数据的封装
│   │   ├── @bcopObj/                  # BCOP 数据的封装
│   │   └── @bcouObj/                  # BCOU 数据的封装
│   ├── misc/                          # 本构模型
│   │   ├── @swccObj/                  # 土壤水分特征曲线对象
│   │   ├── SWCC_Fayer1995WRR.m
│   │   ├── RelativeK_Mualem1976.m
│   │   ├── RelativeK_VanGenuchten1980.m
│   │   ├── adsorption_freundlich.m
│   │   └── adsorption_langmuir.m
│   ├── sutraset/                      # SUTRASET 专用（蒸散发）
│   └── @inpObj/ @icsObj/ @bcsObj/ @filObj/   # 输入文件对象
├── example/
│   ├── SUTRA_examples/2D/
│   │   ├── Henry/                     # Henry 盐水入侵基准算例
│   │   └── Island2D/                  # 岛屿淡水透镜体基准算例
│   ├── plot_swcc_kr_carsel1988/       # Carsel (1988) 土壤 SWCC/Kr 图
│   ├── plot_swcc_kr_marsh/            # Marsh (2012) 土壤 SWCC/Kr 图
│   ├── Sutra_adsorption/              # 吸附模型示例
│   └── America_2019_wrr_case1n_mesh_generation/   # WRR 2019 野外案例
```

---

## 4. 快速入门

**第一步 — 配置路径**
```matlab
run('path_to_SutraLab/mfiles/slsetpath.m')
```

**第二步 — 进入 SUTRA 模拟目录**（`SUTRA.FIL` 所在位置）：
```matlab
cd('path_to_your_simulation')
```

**第三步 — 读取模拟文件**
```matlab
fil  = readFIL;                  % 读取 SUTRA.FIL 获取项目名称
inp  = inpObj(fil.basename);     % 从 .INP 读取网格参数
nod  = readNOD(fil.basename);    % 从 .NOD 读取节点结果
ele  = readELE(fil.basename);    % 从 .ELE 读取单元速度
bcop = readBCOP(fil.basename);   % 指定压力边界输出
bcof = readBCOF(fil.basename);   % 流体源汇输出
```

**第四步 — 访问数据**
```matlab
% 按标签名查找列索引
c_idx = strcmp(nod(1).label, 'Concentration');
x_idx = strcmp(nod(1).label, 'X');
y_idx = strcmp(nod(1).label, 'Y');

% 将一维数组重塑为二维空间矩阵（适用于 2-D REGULAR 网格）
c_matrix = reshape(nod(end).terms{c_idx}, [inp.nn1, inp.nn2]);
x_matrix = reshape(nod(1).terms{x_idx},   [inp.nn1, inp.nn2]);
y_matrix = reshape(nod(1).terms{y_idx},   [inp.nn1, inp.nn2]);

% 绘图
contourf(x_matrix, y_matrix, c_matrix);
colormap(jet); colorbar;
xlabel('x (m)'); ylabel('y (m)');
```

---

## 5. 核心读取函数

所有读取函数遵循相同的调用约定：
```matlab
[data, header] = readXXX(basename, 'outputnumber', N, 'outputfrom', M)
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `basename` | 字符串 | — | 不含扩展名的项目名（如 `'Henry2D'`） |
| `'outputnumber'` | 整数 | 全部 | 读取的时间步数；负数表示从末尾开始读 |
| `'outputfrom'` | 整数 | 1 | 起始时间步索引 |

### 5.1 `readNOD` — 节点结果

```matlab
[nod, nod2] = readNOD(basename)
[nod, nod2] = readNOD(basename, 'outputnumber', 5)    % 前5步
[nod, nod2] = readNOD(basename, 'outputnumber', -3)   % 最后3步
[nod, nod2] = readNOD(basename, 'outputfrom', 10, 'outputnumber', 5)
```

**返回值：**
- `nod` — 结构体数组 `(1 × N_steps)`，每个元素包含：
  - `.itout` — 时间步编号
  - `.tout` — 模拟时间（秒）
  - `.durn` — 步长（秒）
  - `.label` — 输出变量名称的元胞数组（如 `{'Node','X','Y','Pressure','Concentration','Saturation'}`）
  - `.terms` — 数据向量的元胞数组，每列对应一个标签
- `nod2` — 文件头结构体，包含网格元数据：
  - `.nn`、`.ne`、`.nn1`、`.nn2`（三维时还有 `.nn3`）— 网格维度
  - `.mshtyp` — `{维度, 类型}`，如 `{'2-D','REGULAR'}`
  - `.ktprn` — 文件中输出结果的总数
  - `.tt`、`.itt` — 各输出时间点的时间和步号

### 5.2 `readELE` — 单元速度结果

```matlab
[ele, ele2] = readELE(basename)
[ele, ele2] = readELE(basename, 'outputnumber', 10)
```

**返回值：**
- `ele` — 结构体数组 `(1 × N_steps)`，每个元素包含：
  - `.itout`、`.tout`、`.durn` — 时间信息
  - `.label` — 如 `{'Element','X origin','Y origin','X velocity','Y velocity'}`
  - `.terms` — 各标签对应的数据向量
- `ele2` — 文件头结构体（`.ne`、`.nn`、`.mshtyp` 等）

### 5.3 `readBCOP` — 压力边界条件输出

```matlab
[bcop, bcop2] = readBCOP(basename)
```

包含指定压力边界节点的结果。文件头提供 `.npbc`（压力边界节点数）。

### 5.4 `readBCOF` — 流体源汇输出

```matlab
[bcof, bcof2] = readBCOF(basename)
```

包含流体源汇节点的结果。文件头提供 `.nsop`。

### 5.5 `readFIL` — SUTRA 文件列表

```matlab
fil = readFIL            % 读取当前目录下的 SUTRA.FIL
fil = readFIL('path/to/SUTRA.FIL')
```

返回包含 `.basename` 字段的结构体，供其他读取函数使用。

### 5.6 `readINP` — 输入文件网格结构

```matlab
inp2 = readINP(basename)
```

解析 `.INP` 文件，提取：
- `.meshtype` — 网格维度和类型
- `.nn`、`.ne`、`.np`、`.nc`、`.nf`、`.ns`、`.no` — Data Set 3 中的计数
- `.ds22` — 单元关联表（Data Set 22）；二维网格为 5 列，三维为 9 列

---

## 6. 面向对象接口

面向对象封装类（`nodObj`、`eleObj` 等）提供更便捷的数据访问接口，内置矩阵转换和时间平均方法。

### 6.1 `nodObj`

```matlab
nod = nodObj(basename)
nod = nodObj(basename, 'outputnumber', 10)
nod = nodObj(basename, 'mtx_transpose', 'yes')   % 转置重塑
```

**自动计算的索引属性**（从标签名自动填充）：

| 属性 | 说明 |
|------|------|
| `nod.n_idx` | 'Node' 列索引 |
| `nod.x_idx` | 'X' 列索引 |
| `nod.y_idx` | 'Y' 列索引 |
| `nod.z_idx` | 'Z' 列索引 |
| `nod.p_idx` | 'Pressure' 列索引 |
| `nod.c_idx` | 'Concentration' 列索引 |
| `nod.s_idx` | 'Saturation' 列索引 |

**方法：**

| 方法 | 说明 |
|------|------|
| `nod.export('c', 'steps', N)` | 导出第 N 步的浓度数据 |
| `nod.export('c', 'mtx', 'steps', N)` | 以二维矩阵形式导出 |
| `nod.average('c')` | 时间平均浓度 |
| `nod.average('c', 'mtx')` | 时间平均，以矩阵形式 |
| `nod.average('c', 'range', 5:10)` | 对第 5–10 步求平均 |
| `nod.convert_2_mtx(vec)` | 将向量重塑为二维矩阵 |
| `nod.delete_terms(idx)` | 删除不需要的输出列 |

**`del_unfinished_end` 选项**（默认 `'yes'`）：若模拟被中断，自动删除最后一个不完整的输出。

### 6.2 `eleObj`

```matlab
ele = eleObj(basename)
ele = eleObj(basename, 'outputnumber', 5)
```

**自动计算的索引属性：**

| 属性 | 说明 |
|------|------|
| `ele.e_idx` | 'Element' 列 |
| `ele.x_idx` | 'X origin' 列 |
| `ele.y_idx` | 'Y origin' 列 |
| `ele.vx_idx` | 'X velocity' 列 |
| `ele.vy_idx` | 'Y velocity' 列 |
| `ele.vz_idx` | 'Z velocity' 列 |

**方法：**

| 方法 | 说明 |
|------|------|
| `ele.average('vx')` | X 方向速度的时间平均值 |
| `ele.average('vx', 'mtx')` | 以二维矩阵形式返回 |
| `ele.convert_2_mtx(vec)` | 重塑为单元矩阵 |

### 6.3 `bcofObj` 和 `bcopObj`

```matlab
bcof = bcofObj(basename)   % 流体源汇边界条件
bcop = bcopObj(basename)   % 指定压力边界条件
```

均提供 `average` 方法用于对边界通量进行时间平均。

---

## 7. 支持的网格类型

函数式读取器和面向对象封装类均能自动从 `.NOD`/`.ELE` 文件头中识别网格类型，并按对应格式解析维度信息。

| 维度 | 类型 | 提取的变量 | 备注 |
|------|------|-----------|------|
| 2-D | REGULAR | `nn1`、`nn2`、`nn`、`ne` | 结构化矩形网格 |
| 2-D | IRREGULAR | `nn` | 非结构化网格，无维度分量 |
| 3-D | REGULAR | `nn1`、`nn2`、`nn3`、`nn`、`ne` | 结构化三维网格 |
| 3-D | BLOCKWISE | `nn1`、`nn2`、`nn3`、`nn`、`ne` | 块状结构三维网格 |
| 3-D | LAYERED | `nn1`、`nn2`、`nn3`、`nn`、`ne` | 分层结构三维网格 |

对于 2-D REGULAR 网格，可将数据向量重塑为 `[nn1, nn2]` 矩阵：
```matlab
c_matrix = reshape(nod(t).terms{c_idx}, [inp.nn1, inp.nn2]);
```

对于 3-D BLOCKWISE 网格，重塑为 `[nn1, nn2, nn3]`：
```matlab
p_cube = reshape(nod(t).terms{p_idx}, [inp.nn1, inp.nn2, inp.nn3]);
```

---

## 8. 土壤特性模型

### 8.1 `swccObj` — 土壤水分特征曲线

`swccObj` 读取逗号分隔的参数文件，可同时对多种土壤类型计算 SWCC 和相对渗透率曲线。

**参数文件格式**（逗号分隔，每行一种土壤）：
```
soil_type, swres, alpha, vn, ksat, porosity, psim0, comment, line_type
Sandy_loam, 0.065, 7.5, 1.89, 1.06e-5, 0.41, -50, Carsel1988, -
```

**使用示例：**
```matlab
a = swccObj('carsel1988_parameters.dat');
a.psim = -[0:0.01:5, 5:0.1:10, 11:1:100, 200:100:10000]';  % 基质势 (m)

% 计算曲线
a.calc_swcc('type', 'fayer1995');
a.calc_relativek('type', 'mualem1976', 'tortuosity', 0.5);
a.calc_relativek('type', 'mualem1976_sw_stretch');
a.calc_relativek('type', 'tokunaga2009');

% 绘图
figure; a.plot_swcc('type', 'fayer1995');
figure; a.plot_relativek('type', 'mualem1976');
```

**可用 SWCC 模型：** `'fayer1995'` — Fayer & Simmons (1995) 修正 van Genuchten 模型

**可用相对渗透率模型：**

| 模型键值 | 参考文献 | 说明 |
|---------|---------|------|
| `'mualem1976'` | Mualem (1976) | 标准毛细束模型 |
| `'mualem1976_sw_stretch'` | — | 含饱和度拉伸因子的 Mualem 模型 |
| `'tokunaga2009'` | Tokunaga (2009) WRR | 水膜流模型 |
| `'lebeau2010'` | Lebeau (2010) WRR | 水膜流变体 |

### 8.2 独立本构函数

这些函数无需 `swccObj` 即可直接调用：

```matlab
sw = SWCC_Fayer1995WRR(psim, alpha, vn, psim0, swres);
kr = RelativeK_Mualem1976(psim, alpha, vn, 'tortuosity', 0.5);
kr = RelativeK_VanGenuchten1980(psim, alpha, vn, swres);
[kfs, kfr] = FilmRelativeK_Tokunaga2009WRR(psim, T, d, por, n);
cs = adsorption_freundlich(c, kf, nf);
cs = adsorption_langmuir(c, kl, sl_max);
```

---

## 9. 可视化与示例案例

### 9.1 运行示例案例

`example/SUTRA_examples/` 下的每个示例包含两个脚本，需按顺序运行：

1. **`sl_read.m`** — 读取 SUTRA 输出文件并创建索引变量
2. **`sl_analyze.m`** — 将数据重塑为矩阵并生成图形

```matlab
% 在 MATLAB 中进入示例目录：
cd('example/SUTRA_examples/2D/Henry')
run('sl_read.m')
run('sl_analyze.m')
```

### 9.2 Henry 问题（二维盐水入侵）

**位置：** `example/SUTRA_examples/2D/Henry/`

经典 Henry (1964) 基准问题，用于验证变密度流计算。左侧为淡水注入边界，右侧为盐水边界。

**`sl_analyze.m` 生成的图形：**
- 早期和晚期时间步的浓度等值线图
- X 方向和 Y 方向速度等值线图
- 叠加速度箭头（`quiver`）的浓度等值线图
- 饱和度分布图（全域及局部放大）

### 9.3 岛屿问题（二维淡水透镜体）

**位置：** `example/SUTRA_examples/2D/Island2D/`

模拟海岛上淡水透镜体的发育过程，展示 Ghyben-Herzberg 透镜体随时间的演化。绘图模式与 Henry 算例相同。

### 9.4 SWCC 和相对渗透率图

**位置：** `example/plot_swcc_kr_carsel1988/` 和 `example/plot_swcc_kr_marsh/`

```matlab
cd('example/plot_swcc_kr_carsel1988')
run('process_all.m')   % 生成 swcc_all.fig 和 Relative_permeability_all.fig
```

以半对数坐标绘制 Carsel & Parrish (1988) 12 种土壤质地的 SWCC 和 Kr 曲线。

---

## 10. 代码规范

1. **变量名称：** 优先使用 SUTRA 原始代码中的变量名（如 `nn`、`ne`、`npbc`、`nsop`）
2. **新增变量：** 使用小写字母加下划线命名，长度不限，以自解释为准（如 `del_unfinished_end`、`get_relative_k`）
3. **缩进：** 使用制表符（Tab），不使用空格
4. **函数风格：** 新的工具函数遵循 `varargin` + `getProp`/`getNext` 模式，支持灵活的命名参数传递
5. **文件命名：** 读取函数命名为 `readXXX`；类方法文件使用小写字母加下划线
