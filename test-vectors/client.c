#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <sys/random.h>
#include <arpa/inet.h>

int siphash(const uint8_t *in, const size_t inlen, const uint8_t *k,
            uint8_t *out, const size_t outlen);

int print_usage(FILE *fh, const char * prog)
{
	fprintf(fh, "%s [ <server IP> <secret> ]\n", prog);
	return fh == stderr ? 1 : 0;
}

int main(int argc, char * const argv[])
{
	uint8_t cookie[8];
	size_t i;

	if (argc == 3) {
		uint8_t in_buf[32], *in_ptr = in_buf;
		uint8_t secret[16];
		int     a, b, c, d;

		if (inet_pton(AF_INET6, argv[2], in_ptr) == 1)
			in_ptr += 16;

		else if (inet_pton(AF_INET, argv[2], in_ptr) == 1)
			in_ptr += 4;
		else {
			fprintf(stderr, "Error reading server IP\n");
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

	} else if (argc != 1)
		return print_usage(stderr, argv[0]);

	else if (getrandom(cookie, sizeof(cookie), 0) < 0)
		perror("getrandom");

	for (i = 0; i < sizeof(cookie); i++)
		printf("%02x", cookie[i]);

	return 0;
}
