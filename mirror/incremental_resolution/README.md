```bash
(base) [u6059911@notchpeak1:~]$ mkdir -p /scratch/general/vast/u6059911/gsoc/gsoc_spack/mirror_test
(base) [u6059911@notchpeak1:~]$ cd /scratch/general/vast/u6059911/gsoc/gsoc_spack/mirror_test
(base) [u6059911@notchpeak1:mirror_test]$ spack versions kokkos
==> Safe versions (already checksummed):
  develop  5.0.2  5.0.1  5.0.0  4.7.02  4.7.01  4.7.00  4.6.02  4.6.01  4.6.00  4.5.01  4.5.00  4.4.01  4.4.00  4.3.01  4.3.00  4.2.01  4.2.00  4.1.00  4.0.01  4.0.00  3.7.02
==> Remote versions (not yet checksummed):
  5.1.1  5.1.0  4.7.04  4.7.03
```
```bash
(base) [u6059911@notchpeak1:mirror_test]$ spack versions kokkos
==> Safe versions (already checksummed):
  develop  5.0.2  5.0.1  5.0.0  4.7.02  4.7.01  4.7.00  4.6.02  4.6.01  4.6.00  4.5.01  4.5.00  4.4.01  4.4.00  4.3.01  4.3.00  4.2.01  4.2.00  4.1.00  4.0.01  4.0.00  3.7.02
==> Remote versions (not yet checksummed):
  5.1.1  5.1.0  4.7.04  4.7.03
(base) [u6059911@notchpeak1:mirror_test]$ spack mirror create -d mirror kokkos@5.0.2
==> Adding package kokkos@5.0.2 to mirror
    [100%]    1.79 MB @   16.2 MB/s
==> Archive stats:
    0    already present
    1    added
    0    failed to fetch.
```
```bash
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f
mirror/_source-cache/archive/18/188817bb452ca805ee8701f1c5adbbb4fb83dc8d1c50624566a18a719ba0fa5e.tar.gz
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f -exec sha256sum {} \; | sort > hashes_before.txt
(base) [u6059911@notchpeak1:mirror_test]$ cat hashes_before.txt 
188817bb452ca805ee8701f1c5adbbb4fb83dc8d1c50624566a18a719ba0fa5e  mirror/_source-cache/archive/18/188817bb452ca805ee8701f1c5adbbb4fb83dc8d1c50624566a18a719ba0fa5e.tar.gz
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f -exec stat -c "%n %s %Y" {} \; | sort > stats_before.txt
(base) [u6059911@notchpeak1:mirror_test]$ cat stats_before.txt 
mirror/_source-cache/archive/18/188817bb452ca805ee8701f1c5adbbb4fb83dc8d1c50624566a18a719ba0fa5e.tar.gz 1787009 1778364642
```
```bash
(base) [u6059911@notchpeak1:mirror_test]$ spack mirror create -d mirror kokkos@5.0.2
==> Adding package kokkos@5.0.2 to mirror
==> Archive stats:
    1    already present
    0    added
    0    failed to fetch.
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f -exec sha256sum {} \; | sort > hashes_after.txt
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f -exec stat -c "%n %s %Y" {} \; | sort > stats_after.txt
```
```bash
(base) [u6059911@notchpeak1:mirror_test]$ diff hashes_before.txt hashes_after.txt
(base) [u6059911@notchpeak1:mirror_test]$ diff stats_before.txt stats_after.txt
(base) [u6059911@notchpeak1:mirror_test]$ 
```
```bash
(base) [u6059911@notchpeak1:mirror_test]$ cd $SPACK_ROOT
(base) [u6059911@notchpeak1:spack]$ nohup git pull > spack-git_pull.log 2&>1 &
```
```bash
(base) [u6059911@notchpeak1:spack]$ spack versions kokkos
==> Safe versions (already checksummed):
  develop  5.0.2  5.0.1  5.0.0  4.7.02  4.7.01  4.7.00  4.6.02  4.6.01  4.6.00  4.5.01  4.5.00  4.4.01  4.4.00  4.3.01  4.3.00  4.2.01  4.2.00  4.1.00  4.0.01  4.0.00  3.7.02
==> Remote versions (not yet checksummed):
  5.1.1  5.1.0  4.7.04  4.7.03
(base) [u6059911@notchpeak1:spack]$ cd /scratch/general/vast/u6059911/gsoc/gsoc_spack/mirror_test
(base) [u6059911@notchpeak1:mirror_test]$ spack mirror create -d mirror kokkos@develop
==> Adding package kokkos@develop to mirror
Initialized empty Git repository in /tmp/tmpvtnv90ix/kokkos/.git/
==> Archive stats:
    0    already present
    1    added
    0    failed to fetch.
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f
mirror/_source-cache/archive/18/188817bb452ca805ee8701f1c5adbbb4fb83dc8d1c50624566a18a719ba0fa5e.tar.gz
mirror/_source-cache/git/kokkos/kokkos.git/31d48b6dc7465aa484dcd9b532db361d67dfe30b.tar.gz
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f -exec sha256sum {} \; | sort > develop_before.txt
```
```bash
(base) [u6059911@notchpeak1:mirror_test]$ git ls-remote https://github.com/kokkos/kokkos.git | head
31d48b6dc7465aa484dcd9b532db361d67dfe30b	HEAD
85633b0a790d267655e350e076857f6da30b8dd7	refs/heads/cherry-pick/5.1.1/9063
a2d66c92784573f6971c6d37825536fb9b0764d6	refs/heads/cherry-pick/5.1.1/9078
e3a19e1c5bd4dcc5f59fba216b72967692f5a33e	refs/heads/copilot/5-1-1-cherry-pick-patch-releases
384af38709a5069bb3b7c232b6571f34d5d07f3a	refs/heads/copilot/add-tests-for-is-assignable-functionality
31d48b6dc7465aa484dcd9b532db361d67dfe30b	refs/heads/copilot/fix-kokkos-view-pointer-issue
2eb408be120e659d5473023dc8b0f91b8ea26dc4	refs/heads/copilot/fix-race-condition-in-reducers-half-t
31d48b6dc7465aa484dcd9b532db361d67dfe30b	refs/heads/develop
b95780f4ea5b50c765046a8b694a4f196837653d	refs/heads/master
6739bc623081648af9e752b616d9671527922cbf	refs/heads/release-candidate-4.7.02
(base) [u6059911@notchpeak1:mirror_test]$ vim $(spack location -p kokkos)/package.py
(base) [u6059911@notchpeak1:mirror_test]$ spack mirror create -d mirror kokkos@develop
==> Adding package kokkos@develop to mirror
Initialized empty Git repository in /tmp/tmpn9zd8alt/kokkos/.git/
==> Archive stats:
    0    already present
    1    added
    0    failed to fetch.
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f
mirror/_source-cache/archive/18/188817bb452ca805ee8701f1c5adbbb4fb83dc8d1c50624566a18a719ba0fa5e.tar.gz
mirror/_source-cache/git/kokkos/kokkos.git/31d48b6dc7465aa484dcd9b532db361d67dfe30b.tar.gz
mirror/_source-cache/git/kokkos/kokkos.git/b95780f4ea5b50c765046a8b694a4f196837653d.tar.gz
(base) [u6059911@notchpeak1:mirror_test]$ find mirror -type f -exec sha256sum {} \; | sort > develop_after2.txt
(base) [u6059911@notchpeak1:mirror_test]$ diff develop_before.txt develop_after2.txt
2a3
> 7c4c48d965c92332ac1ea8ef657224183c63a70155135ca5fcdc23814d5b57ca  mirror/_source-cache/git/kokkos/kokkos.git/b95780f4ea5b50c765046a8b694a4f196837653d.tar.gz
```