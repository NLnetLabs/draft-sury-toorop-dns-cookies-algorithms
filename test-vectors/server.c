#define _XOPEN_SOURCE
#include <time.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <sys/random.h>
#include <arpa/inet.h>

int siphash(const uint8_t *in, const size_t inlen, const uint8_t *k,
            uint8_t *out, const size_t outlen);

int print_usage(FILE *fh, const char * prog)
{
	fprintf(fh, "%s <client cookie> <client IP> <secret> [ <time> [ <reserved> ] ]\n", prog);
	return fh == stderr ? 1 : 0;
}

int main(int argc, char * const argv[])
{
	uint8_t cookie[8];
	uint8_t in_buf[32], *in_ptr = in_buf;
	uint8_t secret[16];
	int     r1, r2, r3;
	int     a, b, c, d;
	size_t i;
	time_t received;

	if (argc < 4 || argc > 6)
		return print_usage(stderr, argv[0]);

	if (argc > 5) {
		if (sscanf(argv[5], "%2x%2x%2x", &r1, &r2, &r3) != 3) {
			fprintf(stderr, "Error reading reserved bytes\n");
			return 1;
		}
	} else {
		r1 = r2 = r3 = 0;
	}
	if (argc > 4) {
		struct tm tm;
		char *r = strptime(argv[4], "%s", &tm);

		if (!r) {
			fprintf(stderr, "Error reading time\n");
			return 1;
		}
		received = mktime(&tm);
	} else {
		received = time(NULL);
	}
	if (sscanf(argv[1], "%8x%8x", &a, &b) != 2) {
		fprintf(stderr, "Error reading client cookie\n");
		return 1;
	}
	*((uint32_t *)(in_ptr +  0)) = htonl(a);
	*((uint32_t *)(in_ptr +  4)) = htonl(b);
	in_ptr += 8;

	*in_ptr++ = 1;
	*in_ptr++ = (uint8_t)r1;
	*in_ptr++ = (uint8_t)r2;
	*in_ptr++ = (uint8_t)r3;

	*((uint32_t *)(in_ptr +  0)) = htonl((uint32_t)received);
	in_ptr += 4;

	if (inet_pton(AF_INET6, argv[2], in_ptr) == 1)
		in_ptr += 16;

	else if (inet_pton(AF_INET, argv[2], in_ptr) == 1)
		in_ptr += 4;
	else {
		fprintf(stderr, "Error reading client IP\n");
		return 1;
	}

	if (sscanf(argv[3], "%8x%8x%8x%8x", &a, &b, &c, &d) != 4) {
		fprintf(stderr, "Error reading secret\n");
		return 1;
	}
	*((uint32_t *)(secret +  0)) = htonl(a);
	*((uint32_t *)(secret +  4)) = htonl(b);
	*((uint32_t *)(secret +  8)) = htonl(c);
	*((uint32_t *)(secret + 12)) = htonl(d);
	siphash(in_buf, (in_ptr - in_buf), secret, cookie, sizeof(cookie));

	for (i = 0; i < 16; i++)
		printf("%02x", in_buf[i]);
	for (i = 0; i < sizeof(cookie); i++)
		printf("%02x", cookie[i]);

	return 0;
}
