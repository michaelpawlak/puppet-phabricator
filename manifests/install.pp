# == Class: phabricator::install
#
# This module installs Phabricator dependencies.
#
# === Parameters
#
# === Variables
#
# === Examples
#
class phabricator::install inherits ::phabricator {
  # perform our install in order
  anchor { 'phabricator::install::begin': } ->
  class { 'phabricator::install::php5': } ->
  class { 'phabricator::install::repos': } ->
  class { 'phabricator::install::sshhook': } ->
  anchor { 'phabricator::install::end': }
}
