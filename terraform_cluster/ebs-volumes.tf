
resource "aws_ebs_volume" "postgres_volume" {
  availability_zone = "eu-central-1a"
  size              = 4  # Size in GiB
  type              = "io1"
  iops              = 100

  tags = {
    Name = "postgres-volume"
  }
}

output "postgres_volume_id" {
  value = aws_ebs_volume.postgres_volume.id
}
/*
data "template_file" "storage_class" {
  template = file("${path.module}/kubernetes/storage-class.yaml")
}

resource "local_file" "storage_class" {
  content  = data.template_file.storage_class.rendered
  filename = "${path.module}/kubernetes/storage-class.yaml"
}

resource "null_resource" "apply_k8s_storage_class_config" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.storage_class.filename}"
  }

  depends_on = [local_file.storage_class, aws_eks_cluster.this]

}
*/

data "template_file" "persistent_volumes" {
  template = file("${path.module}/kubernetes/postgres-pv.yaml")
  vars = {
    postgres_volume_id = aws_ebs_volume.postgres_volume.id
  }
  depends_on = [ aws_ebs_volume.postgres_volume ]
}

resource "local_file" "persistent_volumes" {
  content  = data.template_file.persistent_volumes.rendered
  filename = "${path.module}/kubernetes/postgres-pv.yaml"
}

resource "null_resource" "apply_k8s_pv_config" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.persistent_volumes.filename}"
  }
  depends_on = [local_file.persistent_volumes, aws_eks_cluster.this, aws_ebs_volume.postgres_volume ]

}

resource "null_resource" "apply_k8s_pvc_config" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes/postgres-claim.yaml"
  }
  depends_on = [null_resource.apply_k8s_pv_config, aws_eks_cluster.this, aws_ebs_volume.postgres_volume]

}
