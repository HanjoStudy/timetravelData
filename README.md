
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

<img src="man/figures/architecture.png" width="1857" />

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

- Example: 10 pages
- Limited: 100 pages
- Top: 10,000 pages

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
# Example API key (this key will only allow 10 search results).
set_api_key("test_the_package")
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
“cotton” is contained in the text. Start by looking up how many *hits*
were seen in the database:

``` r
total_hits <- query_hits("cotton")
```

From the example, we can see that the word “cotton” was observed on
13985 pages. Next we can start retrieving the text:

``` r
out <- query_text(
  query ="cotton",
  from_pos = 0,
  tidy = TRUE
)

out
```

    # A tibble: 10 × 6
       guid_hash            translate pg_nr tokens english_words hightlight
       <chr>                <chr>     <int>  <int>         <int> <list>    
     1 6214a7f9b9ba3d68ba68 no          680    468           163 <chr [19]>
     2 704016213cd70d8cdc58 no           66    349           110 <chr [13]>
     3 e3f7f62e9fae56dbb8cf yes          41    301           103 <chr [9]> 
     4 b364be7f05e40dc2afa4 yes         138    342           135 <chr [15]>
     5 06b3494a9347aad3726c no          194    416           145 <chr [14]>
     6 2154fc604667e60befc6 yes         374    224           102 <chr [7]> 
     7 e3f7f62e9fae56dbb8cf yes          85    216            75 <chr [9]> 
     8 e3f7f62e9fae56dbb8cf yes          49    273           103 <chr [10]>
     9 e3f7f62e9fae56dbb8cf yes          46    304           117 <chr [11]>
    10 e3f7f62e9fae56dbb8cf yes          76    293            85 <chr [10]>

The function has three parameters:

- **query:** This contains the text we want to search.
- **from_pos:** This parameter is used in pagination. See the vignette
  how to page through results.
- **tidy:** The default is to tidy the results in a nested `tibble`
  where the word could have occured more than once on a page

This function outputs SIX columns:

- **guid_hash:** This is the *global unique identifier* and links back
  to a document (not page) within our larger corpus. See below how to
  look up the document meta information.
- **translate:** Was this page translated or not.
- **pg_nr:** This is the *page number* on which the search got a
  positive match.
- **tokens:** Number of tokens on page.
- **english_words:** Number of English Words matched. The English lookup
  had to have *more* (`>`) than 3 characters.
- **type:** We use two types of text extraction methods: `libpoppler`
  from the [`pdftools`](https://github.com/ropensci/pdftools) package,
  as well as the [`tesseract`](https://github.com/ropensci/tesseract)
  library when the `pdftools` library failed. This column indicates
  which tool is displayed.
- **Highlight:** This is the most important column. This contains the
  snippets of where the text matched. To extract the text it is
  suggested to `unnest` the column using the `tidyr` unfunction as:
  `out %>% unnest(hightlight)`.

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
    guid_hash           "6214a7f9b9ba3d68ba68"                                                                                                                            
    orig_file           "fitzgerald_ww_1891_1_english_original.pdf"                                                                                                       
    pdftools_language   "english"                                                                                                                                         
    file_size           "42.8 Mb"                                                                                                                                         
    title               "Travels in the coastlands of British East Africa and the islands of Zanzibar and Pemba; their agricultural resources and general characteristics"
    language            "english"                                                                                                                                         
    nr_pages_text       "822"                                                                                                                                             
    total_tokens        "263126"                                                                                                                                          
    total_english_words "83824"                                                                                                                                           
    pages               "822"                                                                                                                                             

This function outputs nine columns.

### Document Journey

To find the specific associated with a `guid_hash`, you can use
`document_journey`. Some journeys have multiple `guid_hash` identifiers
as multiple volumes were written.

``` r
out <- query_text(
  query ="cotton",
  from_pos = 0,
  tidy = TRUE
)

guid_hash <- unique(out$guid_hash)[1]
document_journey(guid_hash) %>% t
```

               [,1]                                                                                                                                              
    journey_id "fitzgerald_ww_1891"                                                                                                                              
    guid_hash  "6214a7f9b9ba3d68ba68"                                                                                                                            
    orig_file  "fitzgerald_ww_1891_1_english_original.pdf"                                                                                                       
    year_began "1891"                                                                                                                                            
    year_end   "1893"                                                                                                                                            
    title      "Travels in the coastlands of British East Africa and the islands of Zanzibar and Pemba; their agricultural resources and general characteristics"

### Document Traveller

To find the travellers associated with a journey, you need to have a
`journey_id` from `document_journey`

``` r
out <- query_text(
  query ="cotton",
  from_pos = 0,
  tidy = TRUE
)

guid_hash <- unique(out$guid_hash)[1]
journey_id <- document_journey(guid_hash)$journey_id
  
document_traveller(journey_id)
```

    # A tibble: 1 × 11
      journey_id         explorer_first_name explorer_surname title_profession_1
      <chr>              <chr>               <chr>            <chr>             
    1 fitzgerald_ww_1891 William Walter      FitzGerald       hunter            
    # ℹ 7 more variables: title_profession_1_group <chr>, title_profession_2 <lgl>,
    #   title_profession_2_group <lgl>, nationality <chr>, gender <lgl>,
    #   wiki_link <chr>, wiki_url <chr>

### Document Countries

You can also look up the countries that the traveller travelled through
using `guid_hash`:

``` r
out <- query_text(
  query ="cotton",
  from_pos = 0,
  tidy = TRUE
)

guid_hash <- unique(out$guid_hash)[1]
  
document_countries(guid_hash)
```

    # A tibble: 2 × 5
      journey_id         guid_hash            country  country_iso region
      <chr>              <chr>                <chr>    <chr>       <chr> 
    1 fitzgerald_ww_1891 6214a7f9b9ba3d68ba68 kenya    KEN         east  
    2 fitzgerald_ww_1891 6214a7f9b9ba3d68ba68 tanzania TZA         east  

At the same time, you can lookup `historical` and `geographical` place
names in Africa:

``` r
historical_placenames("TZA")
```

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

    Warning: `cols` is now required when using `unnest()`.
    ℹ Please use `cols = c(hightlight)`.

    # A tibble: 44 × 6
       guid_hash            translate pg_nr tokens english_words hightlight         
       <chr>                <chr>     <int>  <int>         <int> <chr>              
     1 8b53b078c4a68bd218b9 no          460    228            72 Still, --New-- --Y…
     2 8b53b078c4a68bd218b9 no          460    228            72 Neither London nor…
     3 8b53b078c4a68bd218b9 no          460    228            72 While the --New-- …
     4 8b53b078c4a68bd218b9 no          460    228            72 Some of the --big-…
     5 8b53b078c4a68bd218b9 no          460    228            72 As for restaurants…
     6 9f12c0ed7ad30e8e63a6 no          117    362           123 When Jack Kkago re…
     7 9f12c0ed7ad30e8e63a6 no          117    362           123 JA CK XKA G O REA …
     8 9f12c0ed7ad30e8e63a6 no          117    362           123 These nkagos have …
     9 9f12c0ed7ad30e8e63a6 no          117    362           123 Jack seemed to hav…
    10 9f12c0ed7ad30e8e63a6 no          117    362           123 home in Newark, --…
    # ℹ 34 more rows

A term can be a single word *quick* or *brown* - or a phrase, surrounded
by double quotes - “quick brown”

``` r
query <- '"new york"'
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using `unnest()`.
    ℹ Please use `cols = c(hightlight)`.

    # A tibble: 38 × 6
       guid_hash            translate pg_nr tokens english_words hightlight         
       <chr>                <chr>     <int>  <int>         <int> <chr>              
     1 7ca8d2a7f75a7d7b97c6 no          340    189            14 Vail, --New-- --Yo…
     2 7ca8d2a7f75a7d7b97c6 no          340    189            14 --New-- --York--, …
     3 7ca8d2a7f75a7d7b97c6 no          340    189            14 James, --New-- --Y…
     4 7ca8d2a7f75a7d7b97c6 no          340    189            14 Esther Herrmann, -…
     5 7ca8d2a7f75a7d7b97c6 no          340    189            14 Gillingham, --New-…
     6 7ca8d2a7f75a7d7b97c6 no          340    189            14 Meyer, --New-- --Y…
     7 04ca493b4a0ca67235e3 yes         459    257            97 --NEW-----YORK-- -…
     8 04ca493b4a0ca67235e3 yes         459    257            97 I cannot say that …
     9 04ca493b4a0ca67235e3 yes         459    257            97 From Niagara Falls…
    10 04ca493b4a0ca67235e3 yes         459    257            97 The best way to ma…
    # ℹ 28 more rows

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

    Warning: `cols` is now required when using `unnest()`.
    ℹ Please use `cols = c(hightlight)`.

    # A tibble: 13 × 6
       guid_hash            translate pg_nr tokens english_words hightlight         
       <chr>                <chr>     <int>  <int>         <int> <chr>              
     1 d5e102415ffcc7ee0fdf no           57    312            99 49 Sohooner --Alig…
     2 d5e102415ffcc7ee0fdf no           57    312            99 Stockton, of the -…
     3 d5e102415ffcc7ee0fdf no           57    312            99 Tuesday Morning, 1…
     4 d5e102415ffcc7ee0fdf no           16    320           109 The period of the …
     5 d5e102415ffcc7ee0fdf no           16    320           109 We had been taught…
     6 b307fd07898c2d10004e no          250    130            14 --Alitor-- 4. Eh n…
     7 99810a792d27f0351a94 no          371    176             1 Ferocidad del --Al…
     8 1209eb31d927d3492fad no          287    192             5 . © 17 40 40 70 43…
     9 99810a792d27f0351a94 no           73    269             6 embriagado , se ar…
    10 99810a792d27f0351a94 no           74    256             8 66 EL VIAGERO UNIV…
    11 c2bcb775ef32fdfa7776 no          248    329            94 It runs very awkwa…
    12 d5e102415ffcc7ee0fdf no           17    340           125 our contract for t…
    13 e7f8f3d24650e830b7f6 no          329    332            17 --Aligator-- Juda …

#### Proximity Search

We can also apply proximity searches:

``` r
query <- '"crocodile shoot"~5'
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using `unnest()`.
    ℹ Please use `cols = c(hightlight)`.

    # A tibble: 14 × 6
       guid_hash            translate pg_nr tokens english_words hightlight         
       <chr>                <chr>     <int>  <int>         <int> <chr>              
     1 8f883596e0ef7831bd51 no          174    277            93 In these some nati…
     2 8f883596e0ef7831bd51 no          174    277            93 appears, Avlien th…
     3 8f883596e0ef7831bd51 no          174    277            93 hide themselves fr…
     4 a84cdc9a0e701b6360fe no          135    196            69 I took a rifle fro…
     5 aa4800b0602890f781f6 no           19    192            65 a --Crocodile-- Th…
     6 aa4800b0602890f781f6 no           19    192            65 Turtle Soup Gazell…
     7 5d764eb59b5587e5e03b no          272    224            77 Hunting again â€”T…
     8 0ba1ee2ca1d36e383b8b no          292    237           101 It is useless to a…
     9 f3879792041cf8bbbadb no           19    227            64 a --Crocodile-- â€…
    10 f3879792041cf8bbbadb no           19    227            64 Gazelle-shootingâ€…
    11 aa4800b0602890f781f6 no           87    287           107 --SHOOT-- A --CROC…
    12 b3f7b94ac2bda5f1693d no          103    297           109 Every traveller up…
    13 5b98c09a6ba6c3f39e80 no           72    285            92 In the morning, th…
    14 aa4800b0602890f781f6 no          133    277           109 --SHOOT-- A MONSTE…

#### Boosting Search

Use the boost operator `^` to make one term more relevant than another:

``` r
query <- '"crocodile^ shoot"~5'
out <- query_text(query)
out %>% unnest()
```

    Warning: `cols` is now required when using `unnest()`.
    ℹ Please use `cols = c(hightlight)`.

    # A tibble: 14 × 6
       guid_hash            translate pg_nr tokens english_words hightlight         
       <chr>                <chr>     <int>  <int>         <int> <chr>              
     1 8f883596e0ef7831bd51 no          174    277            93 In these some nati…
     2 8f883596e0ef7831bd51 no          174    277            93 appears, Avlien th…
     3 8f883596e0ef7831bd51 no          174    277            93 hide themselves fr…
     4 a84cdc9a0e701b6360fe no          135    196            69 I took a rifle fro…
     5 aa4800b0602890f781f6 no           19    192            65 a --Crocodile-- Th…
     6 aa4800b0602890f781f6 no           19    192            65 Turtle Soup Gazell…
     7 5d764eb59b5587e5e03b no          272    224            77 Hunting again â€”T…
     8 0ba1ee2ca1d36e383b8b no          292    237           101 It is useless to a…
     9 f3879792041cf8bbbadb no           19    227            64 a --Crocodile-- â€…
    10 f3879792041cf8bbbadb no           19    227            64 Gazelle-shootingâ€…
    11 aa4800b0602890f781f6 no           87    287           107 --SHOOT-- A --CROC…
    12 b3f7b94ac2bda5f1693d no          103    297           109 Every traveller up…
    13 5b98c09a6ba6c3f39e80 no           72    285            92 In the morning, th…
    14 aa4800b0602890f781f6 no          133    277           109 --SHOOT-- A MONSTE…

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

    Warning: `cols` is now required when using `unnest()`.
    ℹ Please use `cols = c(hightlight)`.

    # A tibble: 36 × 6
       guid_hash            translate pg_nr tokens english_words hightlight         
       <chr>                <chr>     <int>  <int>         <int> <chr>              
     1 a84cdc9a0e701b6360fe no          135    196            69 I took a rifle fro…
     2 a84cdc9a0e701b6360fe no          135    196            69 I had completely r…
     3 a84cdc9a0e701b6360fe no          135    196            69 of a --crocodile--…
     4 a84cdc9a0e701b6360fe no          135    196            69 A --CROCODILE-- GI…
     5 5d764eb59b5587e5e03b no           20    208            69 --Hunting-- again …
     6 5d764eb59b5587e5e03b no           20    208            69 the Setsiebucks â€…
     7 5d764eb59b5587e5e03b no           20    208            69 Lobengula treated …
     8 84a5cc12d1f1d89562c8 yes         460    327           111 Lo Bengula was cau…
     9 84a5cc12d1f1d89562c8 yes         460    327           111 Lo Bengula burst i…
    10 84a5cc12d1f1d89562c8 yes         460    327           111 It should be known…
    # ℹ 26 more rows

states that:

- `hunting` must be present.
- `shoes` must not be present.
- `crocodile` and `shoot` are optional - their presence increases the
  relevance.
