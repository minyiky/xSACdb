# Generated by Django 2.2.7 on 2019-11-06 17:25

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('xsd_frontend', '0002_xsdaction_xsdversion'),
    ]

    operations = [
        migrations.AlterField(
            model_name='updaterequest',
            name='area',
            field=models.CharField(choices=[('mem', 'Membership Details and Renewal'), ('tra', 'Training Records'), ('sit', 'Dive Sites'), ('tri', 'Trips')], max_length=3),
        ),
        migrations.AlterField(
            model_name='updaterequest',
            name='completed',
            field=models.BooleanField(default=False, verbose_name='Mark this issue as fixed'),
        ),
    ]
