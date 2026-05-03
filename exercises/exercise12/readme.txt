# Terragrunt Gateway loadbalancer

+ resource "aws_vpc" "main" {
+ resource "aws_vpc_endpoint" "gwlb_endpoint" {
+ resource "aws_vpc_endpoint_service" "gwlb_service" {

+ resource "aws_subnet" "app" {
+ resource "aws_subnet" "gwlbe" {
+ resource "aws_subnet" "public" {
+ resource "aws_subnet" "security" {

+ resource "aws_route_table" "app" {
+ resource "aws_route_table" "edge" {
+ resource "aws_route_table" "gwlbe" {
+ resource "aws_route_table" "security" {

+ resource "aws_route_table_association" "app_assoc" {
+ resource "aws_route_table_association" "edge_assoc" {
+ resource "aws_route_table_association" "gwlbe_assoc" {
+ resource "aws_route_table_association" "security_assoc" {

+ resource "aws_security_group" "app_sg" {
+ resource "aws_security_group" "sec_sg" {

+ resource "aws_instance" "app" {
+ resource "aws_instance" "security" {

+ resource "aws_internet_gateway" "igw" {

+ resource "aws_lb" "gwlb" {
+ resource "aws_lb_listener" "gwlb_listener" {
+ resource "aws_lb_target_group" "gwlb_tg" {
+ resource "aws_lb_target_group_attachment" "gwlb_attach" {


SIP=
ssh -i sshkey2025ppk.pem ec2-user@$SIP

SIP=54.167.106.200
ssh -i sshkey2025ppk.pem ec2-user@$SIP

sudo tcpdump -nvv 'port 6081'