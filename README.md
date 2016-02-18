## Install HPC-GAP
See [gap-system/gap](https://github.com/gap-system/gap/wiki/Building-HPC-GAP).

## Run Example
```bash
hpcgap
gap> Read("read.g");
gap> Read("test.g");
gap> res := MyOrbits( omega );; time;
gap> Length( res );
gap> Sum( List( res, Length ) );
```
