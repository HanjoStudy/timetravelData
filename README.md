
# timetravelData <img src="man/figures/logo.png" align="right" alt="" width="120" />

Welcome to the [Time Traveller Project!](https://timetraveller.voyage/).

Time Traveller is a digital humanities project that collects, analyses,
and disseminates data about travellers’ observations of pre-colonial
Africa using the latest techniques in computer science.

Very few written primary accounts of pre-colonial Africa exist. This
lack of documented history hinders our understanding of Africa’s past
and long-term trajectory. We collect over 1000 years of African economic
history using handwritten accounts from travellers and their maps.

Analysing such a corpus of text is an insurmountable task for
traditional historians and would probably take a lifetimes work. By
combining modern day computational linguistic techniques in combination
with domain knowledge of African economic history, we build a corpus of
pre-colonial African history across space and time. This large body of
written accounts can be used to systemically shed new light on Africa’s
past.

The project uses multiple open-source tools to make this data available:

![](man/figures/architecture.png)<!-- -->

## Api Interface

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![](https://img.shields.io/github/last-commit/HanjoStudy/timetravelData.svg)](https://github.com/HanjoStudy/timetravelData/commits/develop)

[timetravelData](https://github.com/HanjoStudy/timetravelData) provides
access to over 500,000 pages of travel accounts via an API that is fed
by Elasticsearch.

This is the homepage for the {timetravelData} R package is at
<https://github.com/HanjoStudy/timetravelData>.

The homepage for the {timetravelData} `python` package is *coming
soon!*.

⚠️ The number of results you will be able to return will be dependent on
your level of access:

-   Example: 10 pages
-   Limited: 100 pages
-   Top: 10,000 pages

We are hoping that once we have sufficient funding to expand the
resource capability in order to do away with the tiered system. 😉

## Installation

Install from GitHub.

``` r
remotes::install_github("HanjoStudy/timetravelData")
```

If you want availability to the latest features (at your own risk) then
you can also install from the development branch.

``` r
remotes::install_github("HanjoStudy/timetravelData", ref = "dev")
```

## Usage

``` r
library(timetravelData)
library(tidyr)
```

Check version.

``` r
packageVersion("timetravelData")
```

### Set API Key

To access the API you’ll need to first specify an API key as provided to
you by the project.

``` r
# Example API key (this key will not work).
set_api_key("7b58ffa5afcf893d678433a56e0edca5")
get_api_key()
```

If you wish not to set the key every time, use
`usethis::edit_r_environ()` to set the key to `TIMETRAVELDATA_KEY`.

Please be aware, that there is an order where the API looks for keys:

1)  Look for `ENV` variable, `TIMETRAVELDATA_KEY`, if not found, look in
    `cache` where key was stored using `set_api_key()`
2)  `set_api_key()` OVERRIDES `TIMETRAVELDATA_KEY` in `.Renviron`!

To obtain a key, please get in touch. Contact details are on the
website: <https://timetraveller.voyage/>.

## Full-text Search

### Querying the text

The searching functionality uses a very simple interface through the
`query_text` function. Lets imagine we need to look for whether the word
“cotton” is contained in the text:

``` r
out <- query_text(
  query ="cotton",
  from_pos = 0,
  tidy = TRUE
)

out
```

    # A tibble: 10 × 4
       guid_hash            pg_nr type     hightlight
       <chr>                <int> <chr>    <list>    
     1 b24f414b88a247bd7b5d   680 pdftools <chr [19]>
     2 704016213cd70d8cdc58    66 pdftools <chr [13]>
     3 06b3494a9347aad3726c   194 pdftools <chr [14]>
     4 da787b1696d108219db4    81 pdftools <chr [5]> 
     5 91078ccd5db5d7530e10   299 pdftools <chr [7]> 
     6 b24f414b88a247bd7b5d   396 pdftools <chr [9]> 
     7 e2cc4778a6fb02dca0bd   336 pdftools <chr [8]> 
     8 b24f414b88a247bd7b5d   432 pdftools <chr [11]>
     9 b24f414b88a247bd7b5d   431 pdftools <chr [11]>
    10 b24f414b88a247bd7b5d   679 pdftools <chr [9]> 

The function has three parameters:

-   **query:** This contains the text we want to search.
-   **from_pos:** This parameter is used in pagination. See the vignette
    how to page through results.
-   **tidy:** The default is to tidy the results in a nested `tibble`
    where the word could have occured more than once on a page

This function outputs four columns:

-   **guid_hash:** This is the *global unique identifier* and links back
    to a document (not page) within our larger corpus. See below how to
    look up the document meta information.
-   **pg_nr:** This is the *page number* on which the search got a
    positive match.
-   **type:** We use two types of text extraction methods: `libpoppler`
    from the [`pdftools`](https://github.com/ropensci/pdftools) package,
    as well as the [`tesseract`](https://github.com/ropensci/tesseract)
    library when the `pdftools` library failed. This column indicates
    which tool is displayed.
-   **Highlight:** This is the most important column. This contains the
    snippets of where the text matched. To extract the text it is
    suggested to `unnest` the column using the `tidyr` unfunction as:
    `out %>% unnest(hightlight)`.

You can also look up how many *hits* were seen in the database:

``` r
total_hits <- query_hits("cotton")
```

From the example, we can see that the word “cotton” was observed on 1
pages.

### Document meta

To find the document meta, we need to feed the `document_meta` function
a `guid_hash`

``` r
out <- query_text(
  query ="cotton",
  from_pos = 0,
  tidy = TRUE
)

guid_hash <- unique(out$guid_hash)[1]
document_meta(guid_hash) %>% t
```

                                [,1]                                                                                                                                              
    guid_hash                   "b24f414b88a247bd7b5d"                                                                                                                            
    orig_file                   "fitzgerald_ww_1891_1.pdf"                                                                                                                        
    title                       "Travels in the coastlands of British East Africa and the islands of Zanzibar and Pemba; their agricultural resources and general characteristics"
    pages                       "822"                                                                                                                                             
    file_size                   "42.8 Mb"                                                                                                                                         
    pdftools_english_word_count "235074"                                                                                                                                          
    ocr_english_word_count      "269333"                                                                                                                                          
    cosine_similarity           "0.9878495"                                                                                                                                       
    jaccard_similarity          "0.5376293"                                                                                                                                       

This function outputs nine columns.

### Advance search queries with Lucene notation

#### Basic Search

See full documentation on Elasticsearch’s
[website](https://www.elastic.co/guide/en/elasticsearch/reference/8.4/query-dsl-query-string-query.html#query-string-syntax)

Basic searches uses an analyzer that independently converts each part
into tokens before returning matching documents:

``` r
query <- "(new york city) OR (big apple)"
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using unnest().
    Please use `cols = c(hightlight)`

    # A tibble: 41 × 4
       guid_hash            pg_nr type     hightlight                               
       <chr>                <int> <chr>    <chr>                                    
     1 8b53b078c4a68bd218b9   460 pdftools Still, --New-- --York-- is at best an ex…
     2 8b53b078c4a68bd218b9   460 pdftools Neither London nor Paris compares with -…
     3 8b53b078c4a68bd218b9   460 pdftools While the --New-- --York-- hotels give y…
     4 8b53b078c4a68bd218b9   460 pdftools Some of the --big-- watering-place hotel…
     5 8b53b078c4a68bd218b9   460 pdftools As for restaurants, Paris has fine ones,…
     6 b8c28359ed8d9c6f5894    17 pdftools H^orrfctiou --CITY-- OF --NEW-- --YORK--…
     7 b8c28359ed8d9c6f5894    17 pdftools University of the --City-- of Nnv --York…
     8 b8c28359ed8d9c6f5894    17 pdftools By henry DEAPEE, M.D., Professor of Anal…
     9 e1062b1058b2257f9336   440 pdftools --New-- --York-- in 1879 imported 2,740,…
    10 e1062b1058b2257f9336   440 pdftools The West Indies is the chief seat of Pin…
    # … with 31 more rows

A term can be a single word *quick* or *brown* - or a phrase, surrounded
by double quotes - “quick brown”

``` r
query <- '"new york"'
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using unnest().
    Please use `cols = c(hightlight)`

    # A tibble: 38 × 4
       guid_hash            pg_nr type     hightlight                               
       <chr>                <int> <chr>    <chr>                                    
     1 7ca8d2a7f75a7d7b97c6   340 ocr      Vail, --New-- --York--, N. Y. 3          
     2 7ca8d2a7f75a7d7b97c6   340 ocr      --New-- --York--, N. Y. John E. Hudson, …
     3 7ca8d2a7f75a7d7b97c6   340 ocr      James, --New-- --York--, N. Y. Miss Loui…
     4 7ca8d2a7f75a7d7b97c6   340 ocr      Esther Herrmann, --New-- --York--, N. Y.…
     5 7ca8d2a7f75a7d7b97c6   340 ocr      Gillingham, --New-- --York--, N. Y. Miss…
     6 7ca8d2a7f75a7d7b97c6   340 ocr      Meyer, --New-- --York--, N. Y. John Ervi…
     7 7ca8d2a7f75a7d7b97c6   339 ocr      Isaac Adler, --New-- --York--, N. Y. Sam…
     8 7ca8d2a7f75a7d7b97c6   339 ocr      Daly, --New-- --York--, N. Y. a Charles …
     9 90e6ef9db342542a755c     3 pdftools --NEW-- --YORK-- TROW DIRECTORY, PRINTIN…
    10 90e6ef9db342542a755c     3 pdftools CHIEF OF CLINIC, NERVOUS DEPARTMENT, VAN…
    # … with 28 more rows

#### Fuzzy Search

You can run fuzzy queries using the `~` operator (We have it set to lvl.
1).

> The query uses the Damerau-Levenshtein distance to find all terms with
> a maximum of two changes, where a change is the insertion, deletion or
> substitution of a single character, or transposition of two adjacent
> characters.

``` r
query <- "Aligtor~"
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using unnest().
    Please use `cols = c(hightlight)`

    # A tibble: 11 × 4
       guid_hash            pg_nr type     hightlight                               
       <chr>                <int> <chr>    <chr>                                    
     1 d5e102415ffcc7ee0fdf    57 pdftools "49 Sohooner --Aligator-- arrived at Fou…
     2 d5e102415ffcc7ee0fdf    57 pdftools "Stockton, of the --Aligator--, by whose…
     3 d5e102415ffcc7ee0fdf    57 pdftools "Tuesday Morning, 13th May, 1821. â€”The…
     4 d5e102415ffcc7ee0fdf    16 pdftools "The period of the arrival of the --Alig…
     5 d5e102415ffcc7ee0fdf    16 pdftools "We had been taught to expect the arriva…
     6 b307fd07898c2d10004e   250 pdftools "--Alitor-- 4. Eh neh 5 Ah tong 6. Ah ee…
     7 c2bcb775ef32fdfa7776   248 pdftools "It runs very awkwardly on account of it…
     8 d5e102415ffcc7ee0fdf    17 pdftools "our contract for the lands, and returne…
     9 d7d3313e5665cf123d55     6 pdftools "D. 1185. f \" --Alitor-- elegans et acc…
    10 d5e102415ffcc7ee0fdf    35 pdftools "We regard it as a most favourable provi…
    11 01645ef9996f928b8fd0   103 pdftools "fruits of an intertropical origin flour…

#### Proximity Search

We can also apply proximity searches:

``` r
query <- '"crocodile shoot"~5'
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using unnest().
    Please use `cols = c(hightlight)`

    # A tibble: 13 × 4
       guid_hash            pg_nr type     hightlight                               
       <chr>                <int> <chr>    <chr>                                    
     1 8f883596e0ef7831bd51   174 pdftools In these some natives had been watching,…
     2 8f883596e0ef7831bd51   174 pdftools appears, Avlien they --shoot-- at him wi…
     3 8f883596e0ef7831bd51   174 pdftools hide themselves from view, and rest thei…
     4 a84cdc9a0e701b6360fe   135 pdftools I took a rifle from one of my boys, and …
     5 5d764eb59b5587e5e03b   272 pdftools Hunting again â€”The Premier Nimrod this…
     6 0ba1ee2ca1d36e383b8b   292 pdftools It is useless to attempt to --shoot-- th…
     7 f3879792041cf8bbbadb    19 pdftools a --Crocodile-- â€” The River comes down…
     8 f3879792041cf8bbbadb    19 pdftools Gazelle-shootingâ€” The Speed of the Gaz…
     9 aa4800b0602890f781f6    87 pdftools --SHOOT-- A --CROCODILE--. 51 On 23d Jun…
    10 b3f7b94ac2bda5f1693d   103 ocr      Every traveller up the Nile thinks it hi…
    11 5b98c09a6ba6c3f39e80    72 ocr      In the morning, the first thing I did wa…
    12 aa4800b0602890f781f6   133 pdftools --SHOOT-- A MONSTER. 5 --crocodile-- ; i…
    13 76fe377e10498e382f34   210 ocr      Supposing it to be a --crocodile--, : th…

#### Boosting Search

Use the boost operator `^` to make one term more relevant than another:

``` r
query <- '"crocodile^ shoot"~5'
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using unnest().
    Please use `cols = c(hightlight)`

    # A tibble: 13 × 4
       guid_hash            pg_nr type     hightlight                               
       <chr>                <int> <chr>    <chr>                                    
     1 8f883596e0ef7831bd51   174 pdftools In these some natives had been watching,…
     2 8f883596e0ef7831bd51   174 pdftools appears, Avlien they --shoot-- at him wi…
     3 8f883596e0ef7831bd51   174 pdftools hide themselves from view, and rest thei…
     4 a84cdc9a0e701b6360fe   135 pdftools I took a rifle from one of my boys, and …
     5 5d764eb59b5587e5e03b   272 pdftools Hunting again â€”The Premier Nimrod this…
     6 0ba1ee2ca1d36e383b8b   292 pdftools It is useless to attempt to --shoot-- th…
     7 f3879792041cf8bbbadb    19 pdftools a --Crocodile-- â€” The River comes down…
     8 f3879792041cf8bbbadb    19 pdftools Gazelle-shootingâ€” The Speed of the Gaz…
     9 aa4800b0602890f781f6    87 pdftools --SHOOT-- A --CROCODILE--. 51 On 23d Jun…
    10 b3f7b94ac2bda5f1693d   103 ocr      Every traveller up the Nile thinks it hi…
    11 5b98c09a6ba6c3f39e80    72 ocr      In the morning, the first thing I did wa…
    12 aa4800b0602890f781f6   133 pdftools --SHOOT-- A MONSTER. 5 --crocodile-- ; i…
    13 76fe377e10498e382f34   210 ocr      Supposing it to be a --crocodile--, : th…

#### Boolean

> By default, all terms are optional, as long as one term matches. A
> search for `foo bar baz` will find any document that contains one or
> more of `foo` or `bar` or `baz`. We have already discussed the
> default_operator above which allows you to force all terms to be
> required, but there are also boolean operators which can be used in
> the query string itself to provide more control.

The preferred operators are `+` (this term must be present) and `-`
(this term must not be present). All other terms are optional. For
example, this query:

``` r
query <- "crocodile shoot +hunting -shoes"
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using unnest().
    Please use `cols = c(hightlight)`

    # A tibble: 44 × 4
       guid_hash            pg_nr type     hightlight                               
       <chr>                <int> <chr>    <chr>                                    
     1 a84cdc9a0e701b6360fe   135 pdftools I took a rifle from one of my boys, and …
     2 a84cdc9a0e701b6360fe   135 pdftools I had completely recovered from my littl…
     3 a84cdc9a0e701b6360fe   135 pdftools of a --crocodile-- appeared in the middl…
     4 a84cdc9a0e701b6360fe   135 pdftools A --CROCODILE-- GIVES US A CHILL. 113 st…
     5 5d764eb59b5587e5e03b    20 pdftools --Hunting-- again â€”The Premier Nimrod …
     6 5d764eb59b5587e5e03b    20 pdftools the Setsiebucks â€” prefer --shoot-- not…
     7 5d764eb59b5587e5e03b    20 pdftools Lobengula treated his advisers â€”Traces…
     8 eb92273a13dce38242cc   255 pdftools --HUNTING-- EXPERIENCES. 229 CHAPTER IX. 
     9 eb92273a13dce38242cc   255 pdftools Fortunately however April, the Bushman, …
    10 eb92273a13dce38242cc   255 pdftools Wasps' Xestsâ€” --Crocodile-- Pondâ€” Se…
    # … with 34 more rows

states that:

-   `hunting` must be present.
-   `shoes` must not be present.
-   `crocodile` and `shoot` are optional - their presence increases the
    relevance.
