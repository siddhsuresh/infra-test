terraform {
  required_version = ">= 1.6.0"
}

resource "local_file" "test_file_1" {
  filename = "${path.module}/test-output-1.txt"
  content  = "test-value-1"
}

resource "local_file" "test_file_2" {
  filename = "${path.module}/test-output-2.txt"
  content  = "test-value-2"
}

output "file1_path" {
  value = local_file.test_file_1.filename
}

output "file2_path" {
  value = local_file.test_file_2.filename
}
