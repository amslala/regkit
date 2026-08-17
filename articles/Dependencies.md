# Reference for package dependencies

``` r

library(regkit)
```

The package `regkit` has the following Imports and Suggests:

    #>        type      package  version
    #> 1   Imports        arrow        *
    #> 2   Imports        binom        *
    #> 3   Imports          cli        *
    #> 4   Imports       crayon        *
    #> 5   Imports        dplyr        *
    #> 6   Imports      ggplot2        *
    #> 7   Imports     ggthemes        *
    #> 8   Imports         glue        *
    #> 9   Imports       klassR        *
    #> 10  Imports       logger        *
    #> 11  Imports        purrr        *
    #> 12  Imports        rlang        *
    #> 13  Imports      stringr        *
    #> 14  Imports       tibble        *
    #> 15  Imports        tidyr        *
    #> 16  Imports   tidyselect        *
    #> 17  Imports        withr        *
    #> 18  Depends            R >= 4.1.0
    #> 19 Suggests        haven        *
    #> 20 Suggests PxWebApiData        *
    #> 21 Suggests           sf        *
    #> 22 Suggests     openxlsx        *
    #> 23 Suggests       plotly        *
    #> 24 Suggests      ggrepel        *
    #> 25 Suggests       scales        *
    #> 26 Suggests        knitr        *
    #> 27 Suggests    rmarkdown        *
    #> 28 Suggests     testthat >= 3.0.0

Each of those packages has a number of dependencies (recursive
dependencies):

    #>   [1] "askpass"      "assertthat"   "backports"    "base64enc"    "bit"         
    #>   [6] "bit64"        "brio"         "bslib"        "cachem"       "callr"       
    #>  [11] "checkmate"    "class"        "classInt"     "cli"          "clipr"       
    #>  [16] "crayon"       "crosstalk"    "curl"         "data.table"   "DBI"         
    #>  [21] "desc"         "diffobj"      "digest"       "dplyr"        "e1071"       
    #>  [26] "evaluate"     "farver"       "fastmap"      "fontawesome"  "forcats"     
    #>  [31] "fs"           "generics"     "ggplot2"      "glue"         "graphics"    
    #>  [36] "grDevices"    "grid"         "gtable"       "highr"        "hms"         
    #>  [41] "htmltools"    "htmlwidgets"  "httr"         "igraph"       "isoband"     
    #>  [46] "jquerylib"    "jsonlite"     "KernSmooth"   "knitr"        "labeling"    
    #>  [51] "later"        "lattice"      "lazyeval"     "lifecycle"    "magrittr"    
    #>  [56] "Matrix"       "memoise"      "methods"      "mime"         "NLP"         
    #>  [61] "openssl"      "otel"         "parallel"     "pillar"       "pkgbuild"    
    #>  [66] "pkgconfig"    "pkgload"      "praise"       "processx"     "promises"    
    #>  [71] "proxy"        "ps"           "purrr"        "pxweb"        "R6"          
    #>  [76] "rappdirs"     "RColorBrewer" "Rcpp"         "readr"        "rjstat"      
    #>  [81] "rlang"        "rmarkdown"    "rprojroot"    "s2"           "S7"          
    #>  [86] "sass"         "scales"       "slam"         "stats"        "stringi"     
    #>  [91] "stringr"      "sys"          "tibble"       "tidyr"        "tidyselect"  
    #>  [96] "tinytex"      "tm"           "tools"        "tzdb"         "units"       
    #> [101] "utf8"         "utils"        "vctrs"        "viridisLite"  "vroom"       
    #> [106] "waldo"        "withr"        "wk"           "xfun"         "xml2"        
    #> [111] "yaml"         "zip"

### Dependency tree

You can also visualize how all the dependencies fit together:

    #> ℹ Loading metadata database
    #> ✔ Loading metadata database ... done
    #> 
    #> local::. 0.3.1 [new][bld]
    #> ├─arrow 25.0.0 [new][bld][cmp]
    #> │ ├─assertthat 0.2.1 [new][bld]
    #> │ ├─bit64 4.8.2 [new][bld][cmp]
    #> │ │ └─bit 4.6.0 [new][bld][cmp]
    #> │ ├─cpp11 0.5.5 [new][bld]
    #> │ ├─glue 1.8.1 [new][bld][cmp]
    #> │ ├─purrr 1.2.2 [new][bld][cmp]
    #> │ │ ├─cli 3.6.6 [new][bld][cmp]
    #> │ │ ├─lifecycle 1.0.5 [new][bld]
    #> │ │ │ ├─cli
    #> │ │ │ └─rlang 1.3.0 [new][bld][cmp]
    #> │ │ ├─magrittr 2.0.5 [new][bld][cmp]
    #> │ │ ├─rlang
    #> │ │ └─vctrs 0.7.3 [new][bld][cmp]
    #> │ │   ├─cli
    #> │ │   ├─glue
    #> │ │   ├─lifecycle
    #> │ │   └─rlang
    #> │ ├─R6 2.6.1 [new][bld]
    #> │ ├─rlang
    #> │ ├─tidyselect 1.2.1 [new][bld][cmp]
    #> │ │ ├─cli
    #> │ │ ├─glue
    #> │ │ ├─lifecycle
    #> │ │ ├─rlang
    #> │ │ ├─vctrs
    #> │ │ └─withr 3.0.3 [new][bld]
    #> │ └─vctrs
    #> ├─binom 1.1-2 [new][bld][cmp]
    #> ├─cli
    #> ├─crayon 1.5.3 [new][bld]
    #> ├─dplyr 1.2.1 [new][bld][cmp]
    #> │ ├─cli
    #> │ ├─generics 0.1.4 [new][bld]
    #> │ ├─glue
    #> │ ├─lifecycle
    #> │ ├─magrittr
    #> │ ├─pillar 1.11.1 [new][bld]
    #> │ │ ├─cli
    #> │ │ ├─glue
    #> │ │ ├─lifecycle
    #> │ │ ├─rlang
    #> │ │ ├─utf8 1.2.6 [new][bld][cmp]
    #> │ │ └─vctrs
    #> │ ├─R6
    #> │ ├─rlang
    #> │ ├─tibble 3.3.1 [new][bld][cmp]
    #> │ │ ├─cli
    #> │ │ ├─lifecycle
    #> │ │ ├─magrittr
    #> │ │ ├─pillar
    #> │ │ ├─pkgconfig 2.0.3 [new][bld]
    #> │ │ ├─rlang
    #> │ │ └─vctrs
    #> │ ├─tidyselect
    #> │ └─vctrs
    #> ├─ggplot2 4.0.3 [new][bld]
    #> │ ├─cli
    #> │ ├─gtable 0.3.6 [new][bld]
    #> │ │ ├─cli
    #> │ │ ├─glue
    #> │ │ ├─lifecycle
    #> │ │ └─rlang
    #> │ ├─isoband 0.3.0 [new][bld][cmp]
    #> │ │ ├─cli
    #> │ │ ├─cpp11
    #> │ │ └─rlang
    #> │ ├─lifecycle
    #> │ ├─rlang
    #> │ ├─S7 0.2.2 [new][bld][cmp]
    #> │ ├─scales 1.4.0 [new][bld]
    #> │ │ ├─cli
    #> │ │ ├─farver 2.1.2 [new][bld][cmp]
    #> │ │ ├─glue
    #> │ │ ├─labeling 0.4.3 [new][bld]
    #> │ │ ├─lifecycle
    #> │ │ ├─R6
    #> │ │ ├─RColorBrewer 1.1-3 [new][bld]
    #> │ │ ├─rlang
    #> │ │ └─viridisLite 0.4.3 [new][bld]
    #> │ ├─vctrs
    #> │ └─withr
    #> ├─ggthemes 5.2.0 [new][bld]
    #> │ ├─ggplot2
    #> │ ├─lifecycle
    #> │ ├─purrr
    #> │ ├─scales
    #> │ ├─stringr 1.6.0 [new][bld]
    #> │ │ ├─cli
    #> │ │ ├─glue
    #> │ │ ├─lifecycle
    #> │ │ ├─magrittr
    #> │ │ ├─rlang
    #> │ │ ├─stringi 1.8.9 [new][bld][cmp]
    #> │ │ └─vctrs
    #> │ └─tibble
    #> ├─glue
    #> ├─klassR 1.0.6 [new][bld]
    #> │ ├─httr 1.4.8 [new][bld]
    #> │ │ ├─curl 7.1.0 [new][bld][cmp]
    #> │ │ ├─jsonlite 2.0.0 [new][bld][cmp]
    #> │ │ ├─mime 0.13 [new][bld][cmp]
    #> │ │ ├─openssl 2.4.2 [new][bld][cmp]
    #> │ │ │ └─askpass 1.2.1 [new][bld][cmp]
    #> │ │ │   └─sys 3.4.3 [new][bld][cmp]
    #> │ │ └─R6
    #> │ ├─igraph 2.3.3 [new][bld][cmp]
    #> │ │ ├─cli
    #> │ │ ├─cpp11
    #> │ │ ├─lifecycle
    #> │ │ ├─magrittr
    #> │ │ ├─Matrix 1.7-5 -> 1.7-6 [upd][bld][cmp][dl] (2.53 MB)
    #> │ │ │ └─lattice 0.22-9 -> 0.23-1 [upd][bld][cmp][dl] (682.69 kB)
    #> │ │ ├─pkgconfig
    #> │ │ ├─rlang
    #> │ │ └─vctrs
    #> │ ├─jsonlite
    #> │ └─tm 0.7-19 [new][bld][cmp]
    #> │   ├─BH 1.90.0-1 [new][bld]
    #> │   ├─NLP 0.3-3 [new][bld]
    #> │   ├─Rcpp 1.1.2 [new][bld][cmp]
    #> │   ├─slam 0.1-56 [new][bld][cmp]
    #> │   └─xml2 1.6.0 [new][bld][cmp]
    #> │     ├─cli
    #> │     └─rlang
    #> ├─logger 0.4.2 [new][bld]
    #> ├─purrr
    #> ├─rlang
    #> ├─stringr
    #> ├─tibble
    #> ├─tidyr 1.3.2 [new][bld][cmp]
    #> │ ├─cli
    #> │ ├─cpp11
    #> │ ├─dplyr
    #> │ ├─glue
    #> │ ├─lifecycle
    #> │ ├─magrittr
    #> │ ├─purrr
    #> │ ├─rlang
    #> │ ├─stringr
    #> │ ├─tibble
    #> │ ├─tidyselect
    #> │ └─vctrs
    #> ├─tidyselect
    #> └─withr
    #> 
    #> Key:  [new] new | [upd] update | [dl] download | [bld] build | [cmp] compile
