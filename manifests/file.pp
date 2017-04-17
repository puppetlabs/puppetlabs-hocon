define hocon::file (
  String
    $content,
  String
    $path = $title,
  Enum['present', 'absent']
    $ensure = present,
  Boolean
    $purge = false,
  Variant[Undef, String, Integer]
    $owner = undef,
  Variant[Undef, String, Integer]
    $group = undef,
  Variant[Undef, String]
    $mode = undef,
) {

  file { $path:
    ensure  => $ensure,
    content => $content,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    replace => $purge,
  }

  hocon::resources_from_template(
    $ensure,
    $path,
    $content,
    { 'subscribe' => File[$path] },
  )

}
