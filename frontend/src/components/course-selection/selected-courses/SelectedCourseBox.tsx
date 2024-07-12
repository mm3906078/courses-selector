import {
  AlertDialog,
  AlertDialogBody,
  AlertDialogContent,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogOverlay,
  Box,
  Button,
  Icon,
  Stack,
  Text,
  useDisclosure,
  useToast,
} from "@chakra-ui/react";
import { IoCalendarClearOutline } from "react-icons/io5";
import { LuClock } from "react-icons/lu";
import { MdOutlinePersonOutline } from "react-icons/md";
import { Course } from "../../../models/models";
import { FaRegTrashAlt } from "react-icons/fa";

import { useTranslation } from "react-i18next";
import { useRef } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { axiosInstance } from "../../../api/axiosInstance";

const SelectedCourseBox = (props: Course) => {
  const { t } = useTranslation();
  const {
    isOpen: isUnenrollCourseConfirmOpen,
    onOpen: onOpenUnenrollCourseConfirm,
    onClose: onCloseUnenrollCourseConfirm,
  } = useDisclosure();
  const toast = useToast();
  const cancelRef = useRef(null);
  const queryClient = useQueryClient();
  const unenrollCourseMutation = useMutation({
    mutationFn: () => {
      return axiosInstance.post(`/user/unenroll/${props.course_id}`);
    },
    onSuccess: (res) => {
      onCloseUnenrollCourseConfirm();
      queryClient.invalidateQueries({ queryKey: ["selected-courses"] });
      toast({
        title: "Course Unenrolled!",
        description: `course unenrolled with id of ${res.data.course.course_id}`,
        status: "success",
        duration: 3000,
      });
    },
  });

  const formatDays = (days: string[]): string => {
    let formattedDays = "";
    days.forEach((day) => (formattedDays += `${t(day.toLowerCase())} - `));
    return formattedDays.substring(0, formattedDays.length - 2);
  };

  return (
    <>
      <Box borderRadius="15px" bg="#FEFFDC" padding="20px">
        <Text fontSize="lg">{props.name}</Text>
        <Stack mt="20px">
          <Text>
            <Icon as={MdOutlinePersonOutline} /> {props.professor}
          </Text>
          <Text>
            <Icon as={IoCalendarClearOutline} /> {formatDays(props.days)}
          </Text>
          <Text>
            <Icon as={LuClock} />{" "}
            <Text display="inline" dir="ltr">
              {props.time}
            </Text>
          </Text>
        </Stack>
        <Button
          mt="10px"
          leftIcon={<FaRegTrashAlt size={20} />}
          background="transparent"
          onClick={onOpenUnenrollCourseConfirm}
          color="red"
        >
          {t("deleteCourse")}
        </Button>
      </Box>
      {isUnenrollCourseConfirmOpen && (
        <AlertDialog
          isCentered
          isOpen={isUnenrollCourseConfirmOpen}
          leastDestructiveRef={cancelRef}
          onClose={onCloseUnenrollCourseConfirm}
        >
          <AlertDialogOverlay>
            <AlertDialogContent>
              <AlertDialogHeader fontSize="lg" fontWeight="bold">
                {t("unenrollCourse")}
              </AlertDialogHeader>

              <AlertDialogBody>
                {t("unenrollCourseConfirmMessage")}
              </AlertDialogBody>

              <AlertDialogFooter>
                <Button ref={cancelRef} onClick={onCloseUnenrollCourseConfirm}>
                  {t("cancel")}
                </Button>
                <Button
                  colorScheme="red"
                  onClick={() => {
                    unenrollCourseMutation.mutate();
                  }}
                  marginStart={3}
                >
                  {t("unenroll")}
                </Button>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialogOverlay>
        </AlertDialog>
      )}
    </>
  );
};

export default SelectedCourseBox;
