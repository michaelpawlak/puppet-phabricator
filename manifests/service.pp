# == Class: phabricator::service
#
# This module manages the Phabricator Daemon (phd).
#
# === Parameters
#
# [*service_ensure*]
#
# === Variables
#
# === Examples
#
class phabricator::service inherits ::phabricator {

  anchor { 'phabricator::service::begin': } ->
  class { 'phabricator::service::phd': } ->
  class { 'phabricator::service::sshd': } ->
  anchor { 'phabricator::service::end': }
}
