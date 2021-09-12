output "master_public_ip" {
  value       = aws_eip.master.public_ip
  description = "Master Public IP"
}

output "worker_0_public_ip" {
  value = aws_eip.workers[0].public_ip
}

output "worker_1_public_ip" {
  value = aws_eip.workers[1].public_ip
}
