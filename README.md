# SIMPLY BED TO GFF CONVERTER

 Carlos Peralta 
 
 Instituto de Fisiologia Celular, UNAM

GPL3

---

## Description

This script takes a BED file as an input and return a GFF equivalent to stdout

- Works with BED files with 3 or more columns
    - The intended usage of this program is to convert, for example, ChIP-Seq Peak file/ATAC-Seq peak file or any BED file with a **single** type of feature into a GFF annotation file 
- Any column beyond the 6th is ignored, so this script **should not** be used to attempt creation of multi-features / multi-types GFF.
    - Let me know on the GitHub issues if you would be interested on some kind of multi feature handling (explain your specific needs please)

## Usage

Basic usage 

```bash
./bed2gff.sh  -i {{input BED file}} > {{output GFF file}}
```

Flags

| Argument | Description | Default | Required? |
|----------|-------------|:-------:|:---------:|
| `-i` | Input BED file name or path/name | - | yes |
| `-x` | When present script will ignore every column but the first 3 | - | no |
| `-t {{custom_type_name}}` | This option takes an string to assign a type name to the GFF 3rd column | "peak" | no |
| `-f {{custom_feature_name}}` | This option takes an string to assign a feature name for the unique identifier that will be created at GFF 9th column| "peak" | no |

**Note** If a BED file with a "name" (4th) column is used as input file and no `-x` flag is set an additional bedName feature type will be created at GFF 9th field with the correspondent BED file name for every row.




