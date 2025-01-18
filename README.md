# AWS Lambda API Module

Este repositorio contiene un módulo reutilizable de Terraform que implementa una infraestructura básica en AWS para desplegar:

- **Lambda**: Función en Python con una variable de entorno configurable.
- **API Gateway**: Con conexión a la Lambda y soporte para un autorizador Cognito.
- **WAF**: Configurado para bloquear direcciones IP específicas y limitar la tasa de solicitudes.