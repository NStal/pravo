#!/bin/bash

curl -X POST --data @./cases/data.json http://localhost:8080/me/register
