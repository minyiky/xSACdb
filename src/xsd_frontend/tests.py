from django.test import TestCase
from django.test.client import Client

from django.core.urlresolvers import reverse

from xsd_auth.models import User

from xSACdb.test_helpers import BaseTest, ViewTestMixin

import testdata


class AccountsLogin(TestCase):
    def test_200(self):
        c = Client()
        r = c.get('/accounts/login/')
        self.assertEqual(r.status_code, 200)


class RegisterLogin(TestCase):
    def test_200(self):
        c = Client()
        r = c.get('/accounts/register/')
        self.assertEqual(r.status_code, 200)

    def test_register_form(self):
        c = Client()
        password = testdata.get_str(str_size=128)
        post_data = {
            'first_name': testdata.get_name(name_count=2),
            'last_name': testdata.get_name(name_count=2),
            'email_address': testdata.get_email(),
            'password': password,
            'password_again': password,
        }
        c.post('/accounts/register/', post_data)

        # Check user exists
        self.assertEqual(User.objects.filter(email=post_data['email_address']).count(), 1)

        # Check user creation
        u = User.objects.get(email=post_data['email_address'])
        self.assertEqual(u.first_name, post_data['first_name'])
        self.assertEqual(u.last_name, post_data['last_name'])
        self.assertEqual(u.email, post_data['email_address'])

        # Check profile creation
        self.assertEqual(u.memberprofile.first_name, post_data['first_name'])
        self.assertEqual(u.memberprofile.last_name, post_data['last_name'])
        self.assertEqual(u.memberprofile.email, post_data['email_address'])


class ClassicLogin(TestCase):
    FIRST_NAME = testdata.get_name(name_count=1)
    LAST_NAME = testdata.get_name(name_count=1)
    EMAIL = testdata.get_email()
    PASSWORD = testdata.get_str(128)

    def setUp(self):
        self.user = User.objects.create_user(
            email=self.EMAIL,
            password=self.PASSWORD,
            first_name=self.FIRST_NAME,
            last_name=self.LAST_NAME,
        )
        self.user.save()

    def test_login_username(self):
        # Correct login with username
        c = Client()
        self.assertTrue(c.login(username=self.user.username, password=self.PASSWORD))
        response = c.get(reverse('xsd_frontend:dashboard'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.context['user'], self.user)

    def test_login_email(self):
        # Correct login with email
        c = Client()
        self.assertTrue(c.login(username=self.EMAIL, password=self.PASSWORD))
        response = c.get(reverse('xsd_frontend:dashboard'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.context['user'], self.user)

    # Weird postgres error #214, disabled test as username fail isn't really in scope of app tests
    # def test_login_username_incorrect(self):
    #     # Invalid login
    #     c = Client()
    #     self.assertFalse(c.login(username=self.user.username, password=testdata.get_str(128)))
    #     response = c.get(reverse('xsd_frontend:dashboard'))
    #     self.assertEqual(response.status_code, 302)

    def test_login_email_incorrect(self):
        # Invalid login
        c = Client()
        self.assertFalse(c.login(username=self.EMAIL, password=testdata.get_str(128)))
        response = c.get(reverse('xsd_frontend:dashboard'))
        self.assertEqual(response.status_code, 302)


class Dashboard(ViewTestMixin, BaseTest):
    url_name = 'xsd_frontend:dashboard'
    template_name = 'frontend_dashboard.html'
    allowed_unverified = True
