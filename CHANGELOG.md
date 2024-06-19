# Changelog

## [1.2.1](https://github.com/nvim-neorg/neorg-telescope/compare/v1.2.0...v1.2.1) (2024-06-19)


### Bug Fixes

* backlink file paths ([7bbd96f](https://github.com/nvim-neorg/neorg-telescope/commit/7bbd96fba2b67e33de2b97b1a7b5d2ec4fdd2909))
* escape parens in heading backling search ([cacc934](https://github.com/nvim-neorg/neorg-telescope/commit/cacc934dfd5169e777bd364cf00745e2c9bbf31d))

## [1.2.0](https://github.com/nvim-neorg/neorg-telescope/compare/v1.1.0...v1.2.0) (2024-05-21)


### Features

* add configuration for insert_file_link title ([dd07fc9](https://github.com/nvim-neorg/neorg-telescope/commit/dd07fc9bf3e7862d9700562bc8c0a3761e8a35b4))

## [1.1.0](https://github.com/nvim-neorg/neorg-telescope/compare/v1.0.0...v1.1.0) (2024-04-19)


### Features

* ws relative file/header backlink pickers ([#50](https://github.com/nvim-neorg/neorg-telescope/issues/50)) ([418f8fd](https://github.com/nvim-neorg/neorg-telescope/commit/418f8fd4bd7360d954613a2322b4eb2888ac3ad9))


### Bug Fixes

* call tostring on paths ([a4fc4eb](https://github.com/nvim-neorg/neorg-telescope/commit/a4fc4eb3cd5db6ccd52e99f2b49ce931c458e38f))
* call tostring on workspace paths ([ddd63b5](https://github.com/nvim-neorg/neorg-telescope/commit/ddd63b5301aa0d11c140ab99ba22d0a33a69a9a4))
* cursor behavior on link insertion ([#48](https://github.com/nvim-neorg/neorg-telescope/issues/48)) ([2fb1177](https://github.com/nvim-neorg/neorg-telescope/commit/2fb117727ce91e6ca6209cb1013fb4437bd35722))
* **pathlib:** work with Pathlib objects from neorg &gt;= v8.3.0 ([#58](https://github.com/nvim-neorg/neorg-telescope/issues/58)) ([749c0b1](https://github.com/nvim-neorg/neorg-telescope/commit/749c0b11a4f7150633de8016a8de21a994238643))

## 1.0.0 (2023-08-06)


### ⚠ BREAKING CHANGES

* neorg.modules -> neorg.core
* refactor to accomodate Neorg's breaking changes

### Features

* add `insert_link` command and refactor `find_headings` to `find_linkable` ([90ca150](https://github.com/nvim-neorg/neorg-telescope/commit/90ca15086ab4bb9944df94cc434c0cc4a41aa270))
* add heading picker ([#7](https://github.com/nvim-neorg/neorg-telescope/issues/7)) ([d6089ba](https://github.com/nvim-neorg/neorg-telescope/commit/d6089ba3c1bc8a3c5ce854ce58c6cad42c8de60a))
* added new gtd pickers ([5e144d5](https://github.com/nvim-neorg/neorg-telescope/commit/5e144d51dc51a784ce65cc156b71a9aa602d037c))
* fixed titles ([a44d785](https://github.com/nvim-neorg/neorg-telescope/commit/a44d7852de6b3c78ca271f2189b80bd205b0674f))
* initial project tasks picker ([d067b4f](https://github.com/nvim-neorg/neorg-telescope/commit/d067b4f945464686443c73ea605ead92106dc39e))
* make cursor jump to the end of the link upon insertion ([8d52d0f](https://github.com/nvim-neorg/neorg-telescope/commit/8d52d0fdd391728fe764dd7a02cafa58c284390f))
* **project_task:** added highlights for tasks in preview ([825ba97](https://github.com/nvim-neorg/neorg-telescope/commit/825ba97fb25a33ccc9d5ddbba24005f90c854b1a))
* **project_tasks:** added code to jump to the task ([089998e](https://github.com/nvim-neorg/neorg-telescope/commit/089998ea06345c54d151faeca2183b5a77679880))
* **project_tasks:** added preview and highlight for tasks ([7dc894d](https://github.com/nvim-neorg/neorg-telescope/commit/7dc894dc58c307e3adf2a9c790d840bc946d5b27))
* **project_tasks:** added previewer ([17df8ed](https://github.com/nvim-neorg/neorg-telescope/commit/17df8ed02e8f7898ba7ca22c0142896463eda500))
* **project_tasks:** highlight empty projects with gray ([da5ea13](https://github.com/nvim-neorg/neorg-telescope/commit/da5ea1380d82865ab52e0888e638a10cadc3a371))
* retrieve/generate links for files in the current workspace  ([#2](https://github.com/nvim-neorg/neorg-telescope/issues/2)) ([34a41e8](https://github.com/nvim-neorg/neorg-telescope/commit/34a41e809c427d2d27724358ce40c3a413b99e34))
* show project in preview ([2b40563](https://github.com/nvim-neorg/neorg-telescope/commit/2b405636f8f50d6b839cd4dd39799706ce48780d))
* **switch_workspace:** improved picker ([a8f8003](https://github.com/nvim-neorg/neorg-telescope/commit/a8f8003e8887812c9aa26005c49c8f4c9e3695e5))
* updated to current link format ([#6](https://github.com/nvim-neorg/neorg-telescope/issues/6)) ([2ee2c92](https://github.com/nvim-neorg/neorg-telescope/commit/2ee2c928e2e8cb9eef00acc3ec8c0926d81067ee))


### Bug Fixes

* `core.norg` -&gt; `core` ([#35](https://github.com/nvim-neorg/neorg-telescope/issues/35)) ([787f95c](https://github.com/nvim-neorg/neorg-telescope/commit/787f95c527d4f3fe1c25600e92d939456967e944))
* **aof_tasks:** also get tasks without a project ([c47791c](https://github.com/nvim-neorg/neorg-telescope/commit/c47791c6d8a7817bad5455776d1642dd6302abc2))
* escape special characters in link titles ([0bfbaaf](https://github.com/nvim-neorg/neorg-telescope/commit/0bfbaaf223b8f820f6cb5bdc7a68a44a123a2eeb))
* **find_aof_tasks:** fixed preview ([4dc6699](https://github.com/nvim-neorg/neorg-telescope/commit/4dc66991c3244be99992e9ae6511a6265718f694))
* **find_norg_files:** allow using from not-root of workspace ([197c59a](https://github.com/nvim-neorg/neorg-telescope/commit/197c59a572e4423642b5c5fb727ecefadffe9000))
* **insert_link:** use workspace relative paths fixes [#23](https://github.com/nvim-neorg/neorg-telescope/issues/23) ([4948237](https://github.com/nvim-neorg/neorg-telescope/commit/4948237e593d0ebf5681daecd6d1a6f73130b58e))
* massive overshooting with the insert mode cursor ([965fbe0](https://github.com/nvim-neorg/neorg-telescope/commit/965fbe045ce1814628617325ad51c2698d1b787f))
* neorg.modules -&gt; neorg.core ([d803ae4](https://github.com/nvim-neorg/neorg-telescope/commit/d803ae41c40e3dfa2ac11a4956497436b101ce80))
* **project_tasks:** correctly check for empty project ([15e5957](https://github.com/nvim-neorg/neorg-telescope/commit/15e5957302dff88ceb6378e4c8ae4e70a9221262))
* **project_tasks:** jump to project if it's empty ([d6ff3d5](https://github.com/nvim-neorg/neorg-telescope/commit/d6ff3d5d8698bc417d45ff3bac045fe06cf1d32a))
* Put nvim_buf_get_lines within function call ([e617136](https://github.com/nvim-neorg/neorg-telescope/commit/e61713652020419412d3e1843aca273a0b845928))
* **readme:** fixed github link ([#4](https://github.com/nvim-neorg/neorg-telescope/issues/4)) ([f641eb5](https://github.com/nvim-neorg/neorg-telescope/commit/f641eb530b74cc9bc0e802d1ceca071ed7cada06))
* refactor to accomodate Neorg's breaking changes ([189d551](https://github.com/nvim-neorg/neorg-telescope/commit/189d55168e577945bf13771b63df97bb4bfeffe0))
* require core.norg.dirman ([#1](https://github.com/nvim-neorg/neorg-telescope/issues/1)) ([51973e3](https://github.com/nvim-neorg/neorg-telescope/commit/51973e313395c319365e52f7df76973822e3e773))
* **search_headings:** always get new bufnr ([0aff25f](https://github.com/nvim-neorg/neorg-telescope/commit/0aff25f4ead5d4dc6477dbfecc2de5baed68118d))
* update get_selected_entry_method ([#3](https://github.com/nvim-neorg/neorg-telescope/issues/3)) ([1b273e6](https://github.com/nvim-neorg/neorg-telescope/commit/1b273e6304e4f94a046a847936273be1c56b9cf6))
* use .gif instead of .mp4 ([fd5016b](https://github.com/nvim-neorg/neorg-telescope/commit/fd5016b2b2b9d0be0bbb089a6ef8e75d59460fd6))
* use options parameter for heading picker ([#9](https://github.com/nvim-neorg/neorg-telescope/issues/9)) ([75c2ad0](https://github.com/nvim-neorg/neorg-telescope/commit/75c2ad02d91c353069fdcb55418d4f6eb6aec74e))


### Continuous Integration

* add release please workflow ([9727015](https://github.com/nvim-neorg/neorg-telescope/commit/97270154cc3dd548faea25d4399e80e1efae0a3c))
