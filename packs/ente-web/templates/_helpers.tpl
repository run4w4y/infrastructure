[[- define "docker_config" -]]
config {
  image = "[[ .my.docker_image_registry_url | trimSuffix "/" ]]/[[ .my.docker_image_name ]]:[[ .my.docker_image_tag ]]"

  auth = {
    [[ if empty .my.docker_image_username | not -]]
    username = [[ .my.docker_image_username | quote ]]
    [[- end ]]
    [[ if empty .my.docker_image_password | not -]]
    password = [[ .my.docker_image_password | quote ]]
    [[- end ]]
  }
}
[[- end -]]
